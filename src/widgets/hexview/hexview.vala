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
	const string FONTNAME = ""; //Nimbus Sans L";
	private Context ctx;
	public Hexview.Buffer buffer;

	enum WheelAction {
		PAN   = 0,
		ZOOM  = 1,
	}

	public bool inverse = false;
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
	public Menu menu { set; get; }

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
		this.address = (uint64)this;
		this.buffer = new Buffer ();
		this.set_policy(PolicyType.NEVER, PolicyType.NEVER);
		create_widgets ();
	}

	public enum Color {
		HIGHLIGHT,
		FOREGROUND,
		BACKGROUND
	}

	public void set_color (Color c) {
		if (inverse)
			switch (c) {
			case Color.FOREGROUND:
				ctx.set_source_rgb (1, 1, 1);
				break;
			case Color.BACKGROUND:
				ctx.set_source_rgb (0, 0, 0);
				break;
			case Color.HIGHLIGHT:
				ctx.set_source_rgb (1, 0, 0);
				break;
			}
		else
			switch (c) {
			case Color.FOREGROUND:
				ctx.set_source_rgb (0, 0, 0);
				break;
			case Color.BACKGROUND:
				ctx.set_source_rgb (1, 1, 1);
				break;
			case Color.HIGHLIGHT:
				ctx.set_source_rgb (0.4, 0.4, 1);
				break;
			}
	}

	public void create_widgets () {
		da = new DrawingArea ();
		da.add_events(  Gdk.EventMask.BUTTON1_MOTION_MASK |
				Gdk.EventMask.SCROLL_MASK         |
				Gdk.EventMask.BUTTON_PRESS_MASK   |
				Gdk.EventMask.BUTTON_RELEASE_MASK );
		da.expose_event += expose;
		da.motion_notify_event += motion;
		da.button_release_event += button_release;
		da.button_press_event += button_press;
		da.scroll_event += scroll_press;
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

		refresh (da);
		return false;
	}

	private bool key_release(Gtk.Widget w, Gdk.EventKey ek) {
		this.grab_focus ();
		//stdout.printf("Key released %d (%c)\n", (int)ek.keyval, (int)ek.keyval);
		switch (ek.keyval) {
		case 65507: // CONTROL KEY
			wheel_action = WheelAction.PAN;
			break;
		case 65505: // SHIFT
			wheel_action = WheelAction.PAN;
			break;
		}
		refresh (da);
		return true;
	}

	private bool key_press (Gtk.Widget w, Gdk.EventKey ek) {
		bool handled = true;
		//DrawingArea da = (DrawingArea)w;
		this.grab_focus();

		/* */
		//stdout.printf("Key pressed %d (%c)\n", (int)ek.keyval, (int)ek.keyval);

		switch (ek.keyval) {
		case 'i': // inverse colors
			inverse = !inverse;
			break;
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
//print ("PANY = %f\n", pany);

		refresh(da);

		return true;
	}

	public void do_popup_generic() {
		ImageMenuItem imi;
		menu = new Menu();

		// XXX: most of this should be done in a tab panel or so
		imi = new ImageMenuItem.from_stock("Copy", null);
		imi.activate += imi => {
			stdout.printf("How many bytes?\n");
		};
		menu.append(imi);

		imi = new ImageMenuItem.from_stock("Paste", null);
		imi.activate += imi => {
			stdout.printf("foo\n");
		};
		menu.append(imi);

		imi = new ImageMenuItem.from_stock ("Write", null);
		imi.activate += imi => {
			stdout.printf("TODO\n");
		};
		menu.append(imi);

		imi = new ImageMenuItem.from_stock ("Assemble", null);
		imi.activate += imi => {
			stdout.printf("TODO\n");
		};
		menu.append(imi);

		menu.show_all();
		menu.popup (null, null, null, 0, 0);
	}

	private bool button_press (Gtk.DrawingArea da, Gdk.EventButton eb) {
		int w, h;
		da.window.get_size(out w, out h);

		if (eb.button == 3)
			do_popup_generic();
		if (eb.x < 50)
			breakpoint = address+16*(int)((eb.y-(pany)-(20*zoom))/(lineh*zoom));
		if (eb.x > w-30) {
			int mid = h/2;
			if (eb.y <mid) pany+=40;
			else pany-=40;
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
		draw (true);
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
		/* TODO: handle multipliers here!! */
		if (pany>0) {
			buffer.update (offset-(16*16), 16*80);
			pany -= 80;
			address -= 16*4;
			cursor += 4;
		}
		if (-pany>(80)) {
			buffer.update (offset+(16*16), 16*80);
			pany += 80;
			cursor -= 4;
			address += 16*4;
		}

		/* set offset */
		double py = (-pany/zoom)/10;
		//print ("PANY = %f\n", pany);
		offset = (uint64)(address + (((int)(py)<<4)));
		offset_click = offset + xcursor; // TODO: add Y
	}

	public void draw(bool food) {
		int w, h;
		da.window.get_size (out w, out h);

		sync ();
		/* adapt zoom to size */
		zoom = ((double)w)/500.0;

		ctx = Gdk.cairo_create(da.window);
		//ctx.save();
		ctx.save();
		// Sans Serif
		ctx.select_font_face (FONTNAME, FontSlant.NORMAL, FontWeight.BOLD);
		ctx.set_font_size (10);
		ctx.translate (0, pany);
		ctx.scale (zoom, zoom);
		set_color (Color.BACKGROUND);
		ctx.paint ();
		//		codew.draw(ctx);
		//stdout.printf("widget.draw\n");
		//da.expose(da, null);
		//da.queue_draw_area(0,0,1000,1000);
		set_color (Color.FOREGROUND);
		for (int i=0;i<60;i++) {
			double y = 20+(i*lineh);
			if (i==cursor) {
				ctx.save ();
				ctx.translate (10,y+1);
				//ctx.set_source_rgba(0.1, 0, 0.9, 0.2);
				set_color (Color.HIGHLIGHT);
				square (ctx, 90, lineh+1);
				ctx.fill();
				//ctx.stroke();
				ctx.restore();

				/* draw xcursor */
				ctx.save();
				ctx.translate((xcursor*15)+100, y+1);
				set_color (Color.HIGHLIGHT);
				square (ctx, 14, lineh+1);
				//ctx.fill();
				//ctx.stroke();
				ctx.stroke();
				ctx.restore();

				/* ascii column */
				ctx.save();
				ctx.translate((xcursor*7)+350, y+1);
				set_color (Color.HIGHLIGHT);
				square(ctx, 7, lineh+1);
				//ctx.fill();
				ctx.stroke();
				ctx.restore();
//stdout.printf("xcursor=%d\n", xcursor);
			}
			if ((address+(i*16))==breakpoint) {
				ctx.save();
				ctx.translate (5,y+4);
				set_color (Color.HIGHLIGHT);
				square(ctx, 5, 5);
				ctx.fill();
				//ctx.stroke();
				ctx.restore();
			}
			ctx.move_to (20, y);
			ctx.show_text ("0x%08llx".printf((uint64)address+(i*16)));
			uint8 *ptr = buffer.get_ptr (0, i);
			if (ptr != null) {
				for (int j=0;j<16;j+=2) {
					ctx.move_to (100+(j*15), y);
					ctx.show_text ("%02x%02x".printf (
						ptr[j], ptr[j+1]));
				}
				for (int j=0;j<16;j++) {
					char ch = (char)ptr[j];
					ctx.move_to (350+(j*7), y);
					if (ch<' '||ch>'~')
						ch = '.';
					ctx.show_text ("%c".printf (ch));
				}
			} else {
				if (food) {
					buffer.update (offset, 16*80);
					draw(false);
				}
			}
		}
		ctx.restore();

		/* topline */
		ctx.save();
		ctx.translate (0, 0);
		ctx.set_source_rgba (0.5, 0.5, 0.5, 0.8);
		square (ctx, w, 11*zoom);
		ctx.fill ();
		//---
		ctx.scale (zoom, zoom);
		ctx.move_to (100, 10);
		ctx.select_font_face (FONTNAME, FontSlant.NORMAL, FontWeight.BOLD);
		set_color (Color.BACKGROUND);
		ctx.show_text (" 0  1  2  3   4  5  6  7   8  9  A  B   C  D  E  F");
		//----
		//ctx.move_to (100, 10);
		ctx.move_to (350, 10);
		ctx.show_text ("0123456789ABCDEF");
		ctx.move_to (0, 10);
		ctx.show_text (("0x%08"+uint64.FORMAT_MODIFIER+"x").printf (offset));
		ctx.restore ();

		set_color (Color.HIGHLIGHT);
		/* arrows */
		ctx.save ();
		ctx.translate (w-(zoom*17), h-(16*zoom));
		triangle (ctx, 9*zoom, 9*zoom, true);
		ctx.fill();
		//ctx.stroke ();
		ctx.restore ();
		/*--*/
		ctx.save();
		ctx.translate (w-(17*zoom), zoom*16);
		triangle (ctx, 9*zoom, 9*zoom, false);
		ctx.fill();
		//ctx.stroke();
		ctx.restore();
	}

	public void refresh(DrawingArea da) {
		int w, h;
		da.window.get_size(out w, out h);
		da.queue_draw_area(0, 0, w+200, h+200);
	}
}
