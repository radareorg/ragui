/*
 *  Grava - General purpose codewing library for Vala
 *  Copyright (C) 2007, 2008  pancake <youterm.com>
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

using GLib;
using Cairo;
using Gtk;
using Gdk;

public class Codewidget.Widget : ScrolledWindow {
	enum WheelAction {
		PAN   = 0,
		ZOOM  = 1,
		ROTATE = 2
	}

	const int SIZE = 30;
	const double ZOOM_FACTOR = 0.1;
	[Widget] public DrawingArea da;
	public const double S = 96;
	public double zoom = 1;
	public int cursor = 0;
	public double lineh = 10;
	public int breakpoint = 6;
	public double pany = 0;
	private WheelAction wheel_action = WheelAction.PAN;
	Menu menu;

	/*
	   public signal void load_codew_at(string addr);
	   public signal void breakpoint_at(string addr);
	   public signal void run_cmd(string addr);
	 */

	public Gtk.Widget get_widget()
	{
		return this;
	}

	construct {
/*
		super(	new Adjustment(0, 10, 1000, 2, 100, 1000),
			new Adjustment(0, 10, 1000, 2, 100, 1000));
*/

		//sw = new ScrolledWindow(
		this.set_policy(PolicyType.NEVER, PolicyType.NEVER);
		create_widgets ();
	}

	public void create_widgets ()
	{
		da = new DrawingArea ();

		/* add event listeners */
		da.add_events(  Gdk.EventMask.BUTTON1_MOTION_MASK |
				Gdk.EventMask.SCROLL_MASK         |
				Gdk.EventMask.BUTTON_PRESS_MASK   |
				Gdk.EventMask.BUTTON_RELEASE_MASK );
		//da.set_events(  Gdk.EventMask.BUTTON1_MOTION_MASK );
		// Gdk.EventMask.POINTER_MOTION_MASK );
		da.expose_event += expose;
		da.motion_notify_event += motion;
		da.button_release_event += button_release;
		da.button_press_event += button_press;
		da.scroll_event += scroll_press;

/*
		sw = new ScrolledWindow(
				new Adjustment(0, 10, 1000, 2, 100, 1000),
				new Adjustment(0, 10, 1000, 2, 100, 1000));
*/
		this.set_policy(PolicyType.NEVER, PolicyType.NEVER);

		Viewport vp = new Viewport(
				new Adjustment(0, 10, 1000, 2, 100, 1000),
				new Adjustment(0, 10, 1000, 2, 100, 1000));
		vp.add(da);

		this.add_events(  Gdk.EventMask.KEY_PRESS_MASK | Gdk.EventMask.KEY_RELEASE_MASK);
		this.key_press_event += key_press;
		this.key_release_event += key_release;

		this.add_with_viewport(vp);

		//load_codew_at += (obj, addr) => {
		//			stdout.printf("HOWHOWHOW "+addr);
		//};
	}

	/* capture mouse motion */
	private bool scroll_press (Gtk.DrawingArea da, Gdk.EventScroll es)
	{
		this.grab_focus();

		switch(es.direction) {
		case ScrollDirection.UP:
			switch(wheel_action) {
			case WheelAction.PAN:
				pany += 20;
				break;
			case WheelAction.ZOOM:
				zoom += ZOOM_FACTOR;
				break;
			}
			break;
		case ScrollDirection.DOWN:
			switch(wheel_action) {
			case WheelAction.PAN:
				pany -= 20;
				break;
			case WheelAction.ZOOM:
				zoom -= ZOOM_FACTOR;
				break;
			}
			break;
		}

		refresh(da);
		return false;
	}

	private bool key_release(Gtk.Widget w, Gdk.EventKey ek)
	{
		this.grab_focus();

		//		stdout.printf("Key released %d (%c)\n", (int)ek.keyval, (int)ek.keyval);

		switch (ek.keyval) {
		case 65507: // CONTROL KEY
			wheel_action = WheelAction.PAN;
			break;
		case 65505: // SHIFT
			wheel_action = WheelAction.PAN;
			break;
		}
		refresh(da);

		return true;
	}

	private bool key_press (Gtk.Widget w, Gdk.EventKey ek)
	{
		bool handled = true;
		//DrawingArea da = (DrawingArea)w;
		this.grab_focus();

		/* */
		//stdout.printf("Key pressed %d (%c)\n", (int)ek.keyval, (int)ek.keyval);

		switch (ek.keyval) {
			case '+':
				zoom+=ZOOM_FACTOR;
				break;
			case '-':
				zoom-=ZOOM_FACTOR;
				break;
			case 'J':
				pany-=20*zoom;
				break;
			case 'K':
				pany+=20*zoom;
				break;
			case 65364:
			case 'j':
				cursor++;
				break;
			case 65362:
			case 'k':
				cursor--;
				break;
			case 65507: // CONTROL KEY
				wheel_action = WheelAction.PAN;
				break;
			case 65505: // SHIFT
				wheel_action = WheelAction.PAN;
				break;
			default:
				handled = false;
				break;
		}

		refresh(da);

		return true;
	}

	public void do_popup_generic()
	{
		ImageMenuItem imi;
		menu = new Menu();

		// XXX: most of this should be done in a tab panel or so
		imi = new ImageMenuItem.from_stock("Set breakpoint", null);
		imi.activate += imi => {
			stdout.printf("foo\n");
		};
		menu.append(imi);

		imi = new ImageMenuItem.from_stock("Change opcode", null);
		imi.activate += imi => {
			stdout.printf("redo\n");
		};
		menu.append(imi);

		imi = new ImageMenuItem.from_stock("Nop instruction", null);
		imi.activate += imi => {
			stdout.printf("redo\n");
		};
		menu.append(imi);

		menu.append(new SeparatorMenuItem());

		imi = new ImageMenuItem.from_stock("View in hex", null);
		imi.activate += imi => {
			stdout.printf("redo\n");
		};
		menu.append(imi);
		imi = new ImageMenuItem.from_stock("View in graph", null);
		imi.activate += imi => {
			stdout.printf("redo\n");
		};
		menu.append(imi);

		menu.append(new SeparatorMenuItem());

		imi = new ImageMenuItem.from_stock("Continue until here", null);
		imi.activate += imi => {
			//run_cmd("!step");
			//run_cmd(".!regs*");
			stdout.printf("redo\n");
			//load_codew_at("$$");
		};
		menu.append(imi);

		menu.show_all();
		menu.popup(null, null, null, 0, 0);
	}

	public void do_popup_menu()
	{
		ImageMenuItem imi;
		menu = new Menu();

		//menu.popup(null, null, null, null, eb.button, 0);
		menu.popup(null, null, null, 0, 0);
	}

	private bool button_press (Gtk.DrawingArea da, Gdk.EventButton eb)
	{
		if (eb.button == 3) {
			do_popup_generic();
		}
		
		if (eb.x < 50*zoom)
			breakpoint = (int)((eb.y-(pany)-(20*zoom))/(lineh*zoom));
		int w, h;
		da.window.get_size(out w, out h);
		if (eb.x > w-30) {
			
			if (eb.y <50)
				pany+=20;
			else pany-=20;
		} else
			cursor = (int)((eb.y-(pany)-(20*zoom))/(lineh*zoom));

		refresh(da);
		return true;
	}

	// drag nodes
	private double opanx = 0;
	private double opany = 0;

	private double abs(double x)
	{
		if (x>0)
			return x;
		return -x;
	}

	Node on = null;
	private bool button_release(Gtk.DrawingArea da, Gdk.EventButton em)
	{
		on = null;
		opanx = opany = 0;
		return true;
	}

	private bool motion (Gtk.DrawingArea da, Gdk.EventMotion em)
	{
		this.grab_focus();
		/* pan view */
		if ((opanx!=0) && (opany!=0)) {
			double x = em.x-opanx;
			double y = em.y-opany;
			pany += y;
			//		codew.panx+=x;//*0.8;
			//		codew.pany+=y;//*0.8;
			//codew.draw(Gdk.cairo_create(da.window));
			refresh(da);
		}
		//Graph.selected = null;
		//pany += opany - em.y;
		opanx = em.x;
		opany = em.y;
		return true;
	}

	private bool expose (Gtk.DrawingArea w, Gdk.EventExpose ev)
	{               
		DrawingArea da = (DrawingArea)w;
		draw();
		return true;
	}

	public static void square (Context ctx, double w, double h) {
		ctx.move_to (0, 0);
		ctx.rel_line_to (w, 0);
		ctx.rel_line_to (0, h);
		ctx.rel_line_to (-w, 0);
		ctx.close_path ();
	}

	public static void triangle (Context ctx, double w, double h, bool down) {
		if (down) {
			ctx.move_to (0, 0);
			ctx.rel_line_to (w, 0);
			ctx.rel_line_to (-w/2, h);
			ctx.rel_line_to (-w/2, -h);
		} else {
			ctx.move_to (w/2, 0);
			ctx.rel_line_to (-w/2, h);
			ctx.rel_line_to (w, 0);
			ctx.rel_line_to (-w/2, -h);
		}
		ctx.close_path ();
	}

	public void draw()
	{
		Context ctx = Gdk.cairo_create(da.window);
		//ctx.save();
		ctx.save();
		ctx.translate(0, pany);
		ctx.scale(zoom, zoom);
		ctx.set_source_rgb(1, 1, 1);
		ctx.paint();
		//		codew.draw(ctx);
		//stdout.printf("widget.draw\n");
		//da.expose(da, null);
		//da.queue_draw_area(0,0,1000,1000);
		ctx.set_source_rgb(0, 0, 0);
		for(int i=0;i<80;i++) {
			double y = 20+(i*lineh);
			if (i==cursor) {
				ctx.save();
				ctx.translate(10,y+1);
				ctx.set_source_rgba(0.1, 0, 0.9, 0.4);
				square(ctx, 300, lineh+1);
				ctx.fill();
				//ctx.stroke();
				ctx.restore();
			}
			if (i==breakpoint) {
				ctx.save();
				ctx.translate(5,y+4);
				ctx.set_source_rgba(0.9, 0, 0, 0.8);
				square(ctx, 5, 5);
				ctx.fill();
				//ctx.stroke();
				ctx.restore();
			}
			ctx.move_to(20,y);
			ctx.show_text("0x%08llx".printf(0x8048000+(i*2)));
			ctx.move_to(100,y);
			ctx.show_text("90");
			ctx.move_to(150,y);
			ctx.show_text("nop");
		}
		ctx.stroke();
		ctx.restore();

		/* arrows */
		int w, h;
		da.window.get_size(out w, out h);
	//stdout.printf("%d %d\n", w, h);
			/* upper arrow */
			ctx.save();
			ctx.translate(w-20, 10);
			ctx.set_source_rgba(0.5, 0.5, 0.5, 0.4);
			square(ctx, 15, 15);
			ctx.fill();
			ctx.restore();

			ctx.save();
			ctx.translate(w-17, 12);
			ctx.set_source_rgba(1,1,1,1);
			triangle(ctx, 9,9, false);
			ctx.fill();
			//ctx.stroke();
			ctx.restore();

			/* bottom arrow */
			ctx.save();
			ctx.translate(w-20, h-20);
			ctx.set_source_rgba(0.5, 0.5, 0.5, 0.4);
			square(ctx, 15, 15);
			ctx.fill();
			ctx.restore();

			ctx.save();
			ctx.translate(w-17, h-17);
			ctx.set_source_rgba(1,1,1,1);
			triangle(ctx, 9,9, true);
			ctx.fill();
			//ctx.stroke();
			ctx.restore();

			/* navigation bar */
			ctx.save();
			ctx.translate(w-20, 30);
			ctx.set_source_rgba(0.7, 0.7, 0.7, 0.2);
			square(ctx, 15, h-60);
			ctx.set_line_width(1);
			ctx.stroke();
			ctx.restore();
	}

	public void refresh(DrawingArea da)
	{
		int w, h;
		da.window.get_size(out w, out h);
		da.queue_draw_area(0, 0, w+200, h+200);
	}
}
