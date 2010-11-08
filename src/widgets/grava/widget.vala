/*
 *  Grava - General purpose graphing library for Vala
 *  Copyright (C) 2007-2010  pancake <youterm.com>
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

using Gtk;
using Gdk;
using Cairo;

public class Grava.Widget : VBox {
	enum WheelAction {
		PAN = 0,
		ZOOM = 1,
		ROTATE = 2
	}

	const int SIZE = 30;
	const double ZOOM_FACTOR = 0.1;
	public DrawingArea da;
	public Grava.Graph graph;
	public const double S = 96;
	private WheelAction wheel_action = WheelAction.PAN;
	ScrolledWindow sw;
	Menu menu;

	/* drag nodes */
	private double opanx = 0;
	private double opany = 0;

	private double offx = 0;
	private double offy = 0;

	/* signals */
	public signal void load_graph_at(string addr);
	public signal void breakpoint_at(string addr);
	public signal void run_cmd(string addr);

	public Gtk.Widget get_widget() {
		return this;
	}

	public Widget() {
		//base.VBox (false, 3);
		graph = new Graph();
		graph.update();
		create_widgets ();
	}

	public void create_widgets () {
		da = new DrawingArea ();

		/* add event listeners */
		da.add_events(  Gdk.EventMask.BUTTON1_MOTION_MASK |
				Gdk.EventMask.SCROLL_MASK         |
				Gdk.EventMask.BUTTON_PRESS_MASK   |
				Gdk.EventMask.BUTTON_RELEASE_MASK );
		//da.set_events(  Gdk.EventMask.BUTTON1_MOTION_MASK );
				// Gdk.EventMask.POINTER_MOTION_MASK );
		da.expose_event.connect (expose);
		da.motion_notify_event.connect (motion);
		da.button_release_event.connect (button_release);
		da.button_press_event.connect (button_press);
		da.scroll_event.connect (scroll_press);

		sw = new ScrolledWindow (
			new Adjustment (0, 10, 1000, 2, 100, 1000),
			new Adjustment (0, 10, 1000, 2, 100, 1000));
		sw.set_policy (PolicyType.NEVER, PolicyType.NEVER);
		add (sw);

		Viewport vp = new Viewport (
			new Adjustment (0, 10, 1000, 2, 100, 1000),
			new Adjustment (0, 10, 1000, 2, 100, 1000));
		vp.add (da);

		sw.add_events (Gdk.EventMask.KEY_PRESS_MASK | Gdk.EventMask.KEY_RELEASE_MASK);
		sw.key_press_event.connect (key_press);
		sw.key_release_event.connect (key_release);

		sw.add_with_viewport (vp);

		load_graph_at.connect ((obj, addr) => {
//			stdout.printf("HOWHOWHOW "+addr);
		});
	}

	/* capture mouse motion */
	private bool scroll_press (Gtk.Widget _w, Gdk.EventScroll es) {
		var da = (DrawingArea)_w;
		sw.grab_focus();

		switch (es.direction) {
		case ScrollDirection.UP:
			switch(wheel_action) {
			case WheelAction.PAN:
				graph.pany += 64;
				break;
			case WheelAction.ZOOM:
				//	graph.zoom += ZOOM_FACTOR;
				graph.do_zoom (+ZOOM_FACTOR);
				break;
			case WheelAction.ROTATE:
				graph.angle-=0.04;
				break;
			}
			break;
		case ScrollDirection.DOWN:
			switch(wheel_action) {
			case WheelAction.PAN:
				graph.pany -= 64;
				break;
			case WheelAction.ZOOM:
				//	graph.zoom -= ZOOM_FACTOR;
			graph.do_zoom(-ZOOM_FACTOR);
				break;
			case WheelAction.ROTATE:
				graph.angle+=0.04;
				break;
			}
			break;
		}

		da.queue_draw_area (0, 0, 5000, 2000);
		return false;
	}

	private bool key_release(Gtk.Widget w, Gdk.EventKey ek) {
		sw.grab_focus ();
//		stdout.printf("Key released %d (%c)\n", (int)ek.keyval, (int)ek.keyval);
		switch (ek.keyval) {
		case 65507: // CONTROL KEY
			wheel_action = WheelAction.PAN;
			break;
		case 65505: // SHIFT
			wheel_action = WheelAction.PAN;
			break;
		}
		return true;
	}

	/* TODO: this must be a hookable signal */
	private bool key_press (Gtk.Widget w, Gdk.EventKey ek) {
		bool handled = true;
		sw.grab_focus();

		print ("Key pressed %d (%c)\n", (int)ek.keyval, (int)ek.keyval);

		if (user_key_pressed (w, ek.keyval)) {
			draw();
			return true;
		}

		switch (ek.keyval) {
		case 'b':
		case 65471: // F2 - set breakpoint
			set_breakpoint (null, Graph.selected.get("label"));
			break;
		case 'B':
		//case 65471: // F2 - set breakpoint
			set_breakpoint (null, "-%s".printf(Graph.selected.get("label")));
			break;
		case 'i':
			graph.inverse = !graph.inverse;
			break;
		case 'r':
			graph.update ();
			break;
		case 'S':
			run_cmd ("!stepo");
			run_cmd (".!regs*");
			load_graph_at ("$$");
			break;
		case 's':
		case 65476: // F7 - step
			run_cmd ("!step");
			run_cmd(".!regs*");
			//graph.update();
			load_graph_at("$$");
			break;
		case 65478: // F9 = cont
			run_cmd("!cont");
			run_cmd(".!regs*");
			load_graph_at("$$");
			break;
		case 65507: // CONTROL KEY
			wheel_action = WheelAction.ZOOM;
			break;
		case 65505: // SHIFT
			wheel_action = WheelAction.ROTATE;
			break;
/*
		case 46: // dot. center view on selected node
			if (Graph.selected != null) {
				//sw.get_size(ref w, ref, h);
				graph.panx = -Graph.selected.x + 350;
				graph.pany = -Graph.selected.y + 350;
			}
			graph.select_next();
			Graph.selected = graph.selected;
			Graph.selected.selected = true;
			break;
*/
		case 65056: // shift+tab : select previous
			//graph.select_prev();
			break;
		case 65289: // tab : select next node
			graph.select_next();
			if (graph.selected == null)
				graph.select_next();
			if (Graph.selected != null) {
				//sw.get_size(ref w, ref, h);
				// XXXX get window size
				graph.panx = -Graph.selected.x + 350;
				graph.pany = -Graph.selected.y + 350;
			}
			break;
		case '1':
			graph.zoom = 1;
			graph.panx = graph.pany = 0;
			break;
		case 65361: // arrow left
		case 'h':
			graph.panx+=S*graph.zoom;
			break;
		case 65364: // arrow down
		case 'j':
			graph.pany-=S*graph.zoom;
			break;
		case 65362: // arrow up
		case 'k':
			graph.pany+=S*graph.zoom;
			break;
		case 65363: // arrow right
		case 'l':
			graph.panx-=S*graph.zoom;
			break;
		case 'H':
			graph.panx+=S*graph.zoom;
			if (Graph.selected != null)
				Graph.selected.x-=S*graph.zoom;
			break;
		case 'J':
			graph.pany-=S*graph.zoom;
			if (Graph.selected != null)
				Graph.selected.y+=S*graph.zoom;
			break;
		case 'K':
			graph.pany+=S*graph.zoom;
			if (Graph.selected != null)
				Graph.selected.y-=S*graph.zoom;
			break;
		case 'L':
			if ( wheel_action == WheelAction.ZOOM) {
			} else {
				graph.panx-=S*graph.zoom;
				if (Graph.selected != null)
					Graph.selected.x+=S*graph.zoom;
			}
			break;
		case '.':
			if (Graph.selected != null)
				load_graph_at(Graph.selected.get("label"));
			else graph.select_next();
			break;
		case ':':
run_cmd("s eip");
			load_graph_at("eip");
			Graph.selected = graph.selected = null;
			break;
		case 'u': // undo selection
run_cmd("s-");
load_graph_at("$$");
			graph.undo_select();
			break;
		case 'U': // undo selection
run_cmd("s+");
load_graph_at("$$");
			graph.undo_select();
			break;
		case 't': // selected true branch
			graph.select_true();
			break;
		case 'f': // selected false branch
			graph.select_false();
			break;
		case '+':
			graph.panx -= 50;
			graph.pany -= 50;
			graph.do_zoom(+ZOOM_FACTOR);
			//graph.zoom+=ZOOM_FACTOR;
			break;
		case '-':
			graph.panx += 50;
			graph.pany += 50;
			graph.do_zoom(-ZOOM_FACTOR);
			//graph.zoom-=ZOOM_FACTOR;
			break;
		case '*':
			graph.angle+=0.05;
			break;
		case '/':
			graph.angle-=0.05;
			break;
		default:
			handled = false;
			break;
		}

		//expose(da, ev);
		da.queue_draw_area(0,0,5000,2000);

		return true;
	}

	public void do_popup_generic() {
		ImageMenuItem imi;
 		menu = new Menu();

		/* XXX: most of this should be done in a tab panel or so */
		imi = new ImageMenuItem.from_stock("undo seek", null);
		imi.activate.connect ((imi) => {
			/* foo */
			run_cmd("s-");
			load_graph_at("$$");
		});
		menu.append(imi);

		imi = new ImageMenuItem.from_stock("redo seek", null);
		imi.activate.connect ((imi) => {
			/* foo */
			run_cmd("s+");
			load_graph_at("$$");
		});
		menu.append(imi);

		imi = new ImageMenuItem.from_stock("Seek to eip", null);
		imi.activate.connect ((imi) => {
			/* foo */
			run_cmd("s eip");
			load_graph_at("$$");
		});
		menu.append(imi);

		menu.append(new SeparatorMenuItem());

		imi = new ImageMenuItem.from_stock("Step", null);
		imi.activate.connect ((imi) => {
			/* foo */
			run_cmd("!step");
			run_cmd(".!regs*");
			load_graph_at("$$");
		});
		menu.append(imi);

		imi = new ImageMenuItem.from_stock("Continue", null);
		imi.activate.connect ((imi) => {
			/* foo */
			run_cmd ("!continue");
			run_cmd (".!regs*");
			load_graph_at ("$$");
		});
		menu.append (imi);
		menu.show_all ();
		menu.popup (null, null, null, 0, 0);
	}

	public void do_popup_menu() {
		ImageMenuItem imi;
 		menu = new Menu();

		//imi = new ImageMenuItem.with_label("Focus");
		imi = new ImageMenuItem.from_stock("gtk-zoom-in", null);
		imi.activate.connect ((imi) => {
	//		stdout.printf("go in!\n");
			focus_at_label(null, Graph.selected.get("label"));
			//MenuItem mi = menu.get_active();
			//load_graph_at(((Label)imi.child).get_text()); //"0x400");
			//stdout.printf(" cocococo "+ menu.);
		});
		menu.append(imi);

		imi = new ImageMenuItem.with_label("Breakpoint here");
		imi.activate.connect ((imi) => {
	//		stdout.printf("add bp!\n");
			set_breakpoint(null, Graph.selected.get("label"));
		});
		menu.append(imi);

		imi = new ImageMenuItem.with_label("Remove breakpoint");
		imi.activate.connect ((imi) => {
			unset_breakpoint(null, Graph.selected.get("label"));
		});
		menu.append(imi);

		// TODO: add continue until here
/*
		imi = new ImageMenuItem.with_label("Remove true branch");
		imi.activate.connect ((imi) => {
///			stdout.printf("Focus!\n");
		});
		menu.append(imi);

		imi = new ImageMenuItem.with_label("Remove false branch");
		imi.activate.connect ((imi) => {
	//		print ("Focus!\n");
		});
		menu.append(imi);
*/
		if (graph.selected != null) {
			menu.append(new SeparatorMenuItem());

			foreach(string str in graph.selected.calls) {
				imi = new ImageMenuItem.with_label (str);
				imi.activate.connect ((imi) => {
					//stdout.printf("FUCKME: \n"+imi.submenu_placement());
					load_graph_at(((Label)imi.child).get_text()); //"0x400");
				});
				menu.append (imi);
			}
		}

		menu.show_all();
		//menu.popup(null, null, null, null, eb.button, 0);
		menu.popup(null, null, null, 0, 0);
	}

	private bool button_press (Gtk.Widget _w, Gdk.EventButton eb) {
		var da = (DrawingArea)_w;
		//EventButton eb = event.button;
		//EventMotion em = event.motion; 
		Node n = graph.click (eb.x-graph.panx, eb.y-graph.pany);

		sw.grab_focus();
		graph.selected = n;
		if (eb.button == 3) {
			if (n != null) do_popup_menu ();
			else do_popup_generic ();
		}
		if (n != null) {
			/* XXX this is not scaling properly */
			if (((eb.y-(10*graph.zoom)-graph.pany)<(n.y*graph.zoom))
			  && (eb.x-graph.panx>(n.x+n.w-(10*graph.zoom))*graph.zoom)) {
				n.has_body = !n.has_body;
				n.fit();
			}
			//opanx = graph.zoom*(eb.x-graph.panx); //*graph.zoom;
			//opany = graph.zoom*(eb.y-graph.pany); //*graph.zoom;
			opanx = opany = 0; // already calculated in 2nd motion iteration
			da.queue_draw_area (0, 0, 5000, 3000);
		}
		return true;
	}

	Node on = null;
	private bool button_release(Gtk.Widget w, Gdk.EventButton em) {
		on = null;
		opanx = opany = 0;
		return true;
	}

	private bool motion (Gtk.Widget _w, Gdk.EventMotion em) {
		var da = (DrawingArea)_w;
		Node n = graph.selected; //graph.click(em.x-graph.panx, em.y-graph.pany);
		sw.grab_focus();
		if (n != null) {
			double emx = em.x - graph.panx;
			double emy = em.y - graph.pany;
			/* drag node */
			/* TODO: properly handle the graph.zoom */
			if (n != on) {
				/* offx, offy are the delta between click and node x,y */
				//offx = (emx/graph.zoom - n.x);
				//offy = (emy/graph.zoom - n.y);
				offx = (emx-n.x)/graph.zoom;
				offy = (emy-n.y)/graph.zoom;
				//print ("ONCE DELTA %lf %lf\n", offx, offy);
				offx = 0; offy = 0; // select top-left corner of node
				on = n;
			}

			n.x = (emx - offx)/graph.zoom;
			n.y = (emy - offy)/graph.zoom;

			da.queue_draw_area (0, 0, 5000, 3000);
			Graph.selected = n;
		} else {
			/* pan view */
			if ((opanx!=0) && (opany!=0)) {
				double x = em.x-opanx;
				double y = em.y-opany;
				graph.panx += x;//*0.8;
				graph.pany += y;//*0.8;
				da.queue_draw_area (0, 0, 5000, 3000);
			}
			opanx = em.x;
			opany = em.y;
		}
		return true;
	}

	private bool expose (Gtk.Widget w, Gdk.EventExpose ev) {
		draw ();
		return true;
	}

	public void draw() {
		Context ctx = Gdk.cairo_create(da.window);
		ctx.save();
		if (graph.zoom < 0.05)
			graph.zoom = 0.05;
		graph.draw (ctx);
		ctx.restore ();
		if (separator != 0) {
			ctx.set_source_rgba (0.6, 0.6, 0.6, 0.2);
			ctx.move_to (0, 0);
			Renderer.square (ctx, separator, 2048);
			ctx.fill ();
		}
	}

	public int separator = 0;

	/* XXX : do not make it static */
        public signal int focus_at_label(void *obj, string addr);
        public signal int set_breakpoint(void *obj, string addr);
        public signal int unset_breakpoint(void *obj, string addr);
        public signal bool user_key_pressed(void *obj, uint key);
#if 0
        [Import]
        [CCode (cname="core_load_graph_at_label")]
        public static extern void focus_at_label(void *obj, string addr);

        [Import]
        [CCode (cname="mygrava_bp_at")]
        public static extern void set_breakpoint(void *obj, string addr);

        [Import]
        [CCode (cname="mygrava_bp_rm_at")]
        public static extern void unset_breakpoint(void *obj, string addr);
#endif
}
