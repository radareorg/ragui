/*
 *  Grava - General purpose codewing library for Vala
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

using GLib;
using Cairo;
using Gtk;
using Gdk;

public class Hexview.Widget : ScrolledWindow {
	const string FONTNAME = "Sans Serif"; //Inconsolata";

	public Hexview.Buffer buffer;

	enum WheelAction {
		PAN   = 0,
		ZOOM  = 1,
	}

	const int SIZE = 30;
	const double ZOOM_FACTOR = 0.1;
	[Widget] public DrawingArea da;
	public const double S = 96;
	public double zoom = 1.4;
	public double lineh = 10; // MUST BE STATIC
	public uint64 breakpoint = 0;
	public double pany = 0;
	private double opanx = 0;
	private double opany = 0;
	private WheelAction wheel_action = WheelAction.PAN;
	Menu menu;

	public uint64 address = 0x8049000;
	public uint64 offset;
	public uint64 offset_click;
	public int cursor = 0;
	public int xcursor = 0;
	public uint64 selfrom = -1LL;
	public uint64 selto = -1LL;

	/*
	   public signal void load_codew_at(string addr);
	   public signal void breakpoint_at(string addr);
	   public signal void run_cmd(string addr);
	 */

	construct {
		this.buffer = new Buffer ();
		this.set_policy(PolicyType.NEVER, PolicyType.NEVER);
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
		this.set_policy (PolicyType.NEVER, PolicyType.NEVER);

		Viewport vp = new Viewport (
			new Adjustment (0, 10, 1000, 2, 100, 1000),
			new Adjustment (0, 10, 1000, 2, 100, 1000));
		vp.add(da);

		this.add_events (Gdk.EventMask.KEY_PRESS_MASK | Gdk.EventMask.KEY_RELEASE_MASK);
		this.key_press_event += key_press;
		this.key_release_event += key_release;

		this.add_with_viewport(vp);
	}

	/* capture mouse motion */
	private bool scroll_press (Gtk.DrawingArea da, Gdk.EventScroll es) {
		this.grab_focus();

		switch(es.direction) {
		case ScrollDirection.UP:
			switch(wheel_action) {
			case WheelAction.PAN:
				pany += 300*ZOOM_FACTOR;
				break;
			case WheelAction.ZOOM:
				zoom += ZOOM_FACTOR;
				break;
			}
			break;
		case ScrollDirection.DOWN:
			switch(wheel_action) {
			case WheelAction.PAN:
				pany -= 300*ZOOM_FACTOR;
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

	private bool key_release(Gtk.Widget w, Gdk.EventKey ek) {
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

	private bool key_press (Gtk.Widget w, Gdk.EventKey ek) {
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
			case 65365: // re.pag
				pany+=100*zoom;
				break;
			case 65366: // av.pag
				pany-=100*zoom;
				break;
			case 65364:
			case 'j':
				cursor++;
				break;
			case 65362:
			case 'k':
				cursor--;
				break;
			case 'l':
				xcursor++;
				if (xcursor>15) {
					xcursor=0;
					cursor++;
				}
				break;
			case 'h':
				xcursor--;
				if (xcursor<0) {
					xcursor=15;
					cursor--;
				}
				break;
			case 65507: // CONTROL KEY
				wheel_action = WheelAction.PAN;
				break;
			case 65505: // SHIFT
				wheel_action = WheelAction.ZOOM;
				break;
			default:
				handled = false;
				break;
		}
print ("PANY = %f\n", pany);

		refresh(da);

		return true;
	}

	public void do_popup_generic() {
		ImageMenuItem imi;
		menu = new Menu();

		// XXX: most of this should be done in a tab panel or so
		imi = new ImageMenuItem.from_stock("Copy", null);
		imi.activate += imi => {
			stdout.printf("foo\n");
		};
		menu.append(imi);

		imi = new ImageMenuItem.from_stock("Paste", null);
		imi.activate += imi => {
			stdout.printf("foo\n");
		};
		menu.append(imi);

		imi = new ImageMenuItem.from_stock("Overwrite", null);
		imi.activate += imi => {
			stdout.printf("foo\n");
		};
		menu.append(imi);

		var mi = new CheckMenuItem.with_label("Fix zoom");
		mi.toggled += mi => {
			stdout.printf("foo %d\n", (int)mi.get_active());
			mi.set_active(!mi.get_active());
			//mi.activate_item();
		//	var active = mi.get_active();
			//mi.active = !mi.active;
		};
		menu.append(mi);

		imi = new ImageMenuItem.from_stock("hexwidth=16", null);
		imi.activate += imi => {
			stdout.printf("foo\n");
		};
		menu.append(imi);

		menu.show_all();
		menu.popup(null, null, null, 0, 0);
	}

	private bool button_press (Gtk.DrawingArea da, Gdk.EventButton eb) {
		int w, h;
		da.window.get_size(out w, out h);

		if (eb.button == 3)
			do_popup_generic();
		if (eb.x < 50)
			breakpoint = address+16*(int)((eb.y-(pany)-(20*zoom))/(lineh*zoom));
		if (eb.x > w-30) {
			if (eb.y <50) pany+=20;
			else pany-=20;
		} else cursor = (int)((eb.y-(pany)-(20*zoom))/(lineh*zoom));

stdout.printf ("x=%f y=%f zoom=%f xz=%f\n", eb.x, eb.y, zoom, eb.x/zoom);
		if ((eb.x/zoom)>100 && ((eb.x/zoom)<340)) {
			double x = (eb.x/zoom)-100;
			xcursor = (int)(x/15);
		} else
		if ((eb.x/zoom)>350 && ((eb.x/zoom)<460)) {
			double x = (eb.x/zoom)-350;
			xcursor = (int)(x/7);
		}

		refresh (da);
		return true;
	}

/*
	private double abs(double x)
	{
		if (x>0)
			return x;
		return -x;
	}
*/

	Node on = null;
	private bool button_release(Gtk.DrawingArea da, Gdk.EventButton em) {
		on = null;
		opanx = opany = 0;
		return true;
	}

	private bool motion (Gtk.DrawingArea da, Gdk.EventMotion em) {
		this.grab_focus();
		/* pan view */
		if ((opanx!=0) && (opany!=0)) {
		//	double x = em.x-opanx;
		//	double y = em.y-opany;
			pany += (em.y-opany);
			refresh(da);
		}
		opanx = em.x;
		opany = em.y;
		return true;
	}

	private bool expose (Gtk.DrawingArea w, Gdk.EventExpose ev) {               
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

	private void sync () {
		if (pany>0) {
			buffer.update (offset-(16*16), 16*64);
			pany -= 80;
			address -= 16*4;
		}
		if (-pany>(80)) {
			print ("MUST UPDATE FORWARD\n");
			buffer.update (offset+(16*16), 16*64);
			pany += 80;
			address += 16*4;
		}

		/* set offset */
		double py = (-pany/zoom)/10;
		print ("PANY = %f\n", pany);
		offset = (uint64)(address + (((int)(py)<<4)));
		offset_click = offset + xcursor; // TODO: add Y
		/*
		if (offset+99999 > buffer.end) {
			pany = 0;
			buffer.update ();
		}
		if (offset < buffer.start) {
			pany = 0;
			buffer.update ();
		}
		*/
	}

	public void draw() {
		int w, h;
		da.window.get_size (out w, out h);

		sync ();
		/* adapt zoom to size */
		zoom = ((double)w)/500.0;

		Context ctx = Gdk.cairo_create(da.window);
		//ctx.save();
		ctx.save();
		// Sans Serif
		ctx.select_font_face(FONTNAME, FontSlant.NORMAL, FontWeight.BOLD);
		ctx.set_font_size(10);
		ctx.translate(0, pany);
		ctx.scale(zoom, zoom);
		ctx.set_source_rgb(0, 0, 0);
		ctx.paint();
		//		codew.draw(ctx);
		//stdout.printf("widget.draw\n");
		//da.expose(da, null);
		//da.queue_draw_area(0,0,1000,1000);
		ctx.set_source_rgb (1, 1, 1);
		for (int i=0;i<40;i++) {
			double y = 20+(i*lineh);
			if (i==cursor) {
				ctx.save ();
				ctx.translate (10,y+1);
				//ctx.set_source_rgba(0.1, 0, 0.9, 0.2);
				ctx.set_source_rgba(1.0, 0.1, 0.1, 0.8);
				square(ctx, 90, lineh+1);
				ctx.fill();
				//ctx.stroke();
				ctx.restore();

				/* draw xcursor */
				ctx.save();
				ctx.translate((xcursor*15)+100, y+1);
				ctx.set_source_rgba(1.0, 0.1, 0.1, 0.8);
				square(ctx, 14, lineh+1);
				ctx.fill();
				//ctx.stroke();
				ctx.restore();

				/* ascii column */
				ctx.save();
				ctx.translate((xcursor*7)+350, y+1);
				//ctx.set_source_rgba(0.3, 0, 0.9, 0.4);
				ctx.set_source_rgba(1.0, 0.1, 0.1, 0.8);
				square(ctx, 7, lineh+1);
				ctx.fill();
				//ctx.stroke();
				ctx.restore();
//stdout.printf("xcursor=%d\n", xcursor);
			}
			if ((address+(i*16))==breakpoint) {
				ctx.save();
				ctx.translate (5,y+4);
				ctx.set_source_rgba (0.9, 0, 0, 0.8);
				square(ctx, 5, 5);
				ctx.fill();
				//ctx.stroke();
				ctx.restore();
			}
			ctx.move_to(20,y);
			ctx.show_text("0x%08llx".printf((uint64)address+(i*16)));
			if (buffer.get_ptr(0,0) != null) {
			for (int j=0;j<8;j++) {
				ctx.move_to (100+(j*30), y);
				uint8 *ptr = buffer.get_ptr (j*2, i);
				ctx.show_text ("%02x%02x".printf (
					ptr[0], ptr[1]));
			}
			for (int j=0;j<16;j++) {
				uint8 *ptr = buffer.get_ptr (j, i);
				char ch = (char)ptr[0];
				ctx.move_to(350+(j*7), y);
				if (ch<' '||ch>'~')
					ch = '.';
				ctx.show_text("%c".printf (ch));
			}
			}
		}
		ctx.stroke();
		ctx.restore();

		/* topline */
		ctx.save();
		ctx.translate(0, 0);
		ctx.set_source_rgba(0.5, 0.5, 0.5, 0.9);
		square(ctx, w, 11*zoom);
		ctx.fill();
		ctx.restore();

		ctx.save();
		ctx.scale (zoom, zoom);
		ctx.move_to (100, 10);
		ctx.select_font_face (FONTNAME, FontSlant.NORMAL, FontWeight.BOLD);
		ctx.set_source_rgb (0, 0, 0);
		ctx.show_text (" 0  1  2  3   4  5  6  7   8  9  A  B   C  D  E  F");
		ctx.restore ();

		ctx.scale (zoom, zoom);
		ctx.save ();
		ctx.move_to (100, 10);
		ctx.select_font_face (FONTNAME, FontSlant.NORMAL, FontWeight.BOLD);
		ctx.set_source_rgb (0, 0, 0);

		ctx.move_to (350, 10);
		ctx.show_text ("0123456789ABCDEF");

		ctx.move_to (0, 10);
		ctx.show_text (("0x%08"+uint64.FORMAT_MODIFIER+"x").printf (offset));
		ctx.restore ();

		/* arrows */
	//stdout.printf("%d %d\n", w, h);
		/* upper arrow */
		ctx.save ();
		ctx.translate (w-20, 20+5);
		ctx.set_source_rgba (0.5, 0.5, 0.5, 0.6);
		square (ctx, 15, 15);
		ctx.fill ();
		ctx.restore ();

		ctx.save();
		ctx.translate(w-17, 20+6);
		ctx.set_source_rgba(1,1,1,1);
		triangle(ctx, 9,9, false);
		ctx.fill();
		//ctx.stroke();
		ctx.restore();

		/* bottom arrow */
		ctx.save();
		ctx.scale(zoom, zoom);
		ctx.translate(w-20, h-20);
		ctx.set_source_rgba(0.5, 0.5, 0.5, 0.6);
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
		ctx.translate (w-20, 25);
		ctx.set_source_rgba (0.7, 0.7, 0.7, 0.3);
		square (ctx, 15, h-50);
		ctx.set_line_width (1);
		ctx.fill ();
		ctx.restore ();
	}

	public void refresh(DrawingArea da) {
		int w, h;
		da.window.get_size(out w, out h);
		da.queue_draw_area(0, 0, w+200, h+200);
	}
}
