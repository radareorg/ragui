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


public class Grava.Widget : GLib.Object {
	enum WheelAction {
		PAN   = 0,
		ZOOM  = 1,
		ROTATE = 2
	}

	const int SIZE = 30;
	const double ZOOM_FACTOR = 0.1;
	[Widget] public DrawingArea da;
	public CodeWidget codew;
	public const double S = 96;
	private WheelAction wheel_action = WheelAction.PAN;
	ScrolledWindow sw;
	Menu menu;

	public signal void load_codew_at(string addr);
	public signal void breakpoint_at(string addr);
	public signal void run_cmd(string addr);

	public Gtk.Widget get_widget()
	{
		return sw;
	}

	construct {
		codew = new CodeWidget();
		codew.update();
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

		sw = new ScrolledWindow(
			new Adjustment(0, 10, 1000, 2, 100, 1000),
			new Adjustment(0, 10, 1000, 2, 100, 1000));
		sw.set_policy(PolicyType.NEVER, PolicyType.NEVER);

		Viewport vp = new Viewport(
			new Adjustment(0, 10, 1000, 2, 100, 1000),
			new Adjustment(0, 10, 1000, 2, 100, 1000));
		vp.add(da);

		sw.add_events(  Gdk.EventMask.KEY_PRESS_MASK | Gdk.EventMask.KEY_RELEASE_MASK);
		sw.key_press_event += key_press;
		sw.key_release_event += key_release;

		sw.add_with_viewport(vp);

		load_codew_at += (obj, addr) => {
//			stdout.printf("HOWHOWHOW "+addr);
		};
	}

	/* capture mouse motion */
	private bool scroll_press (Gtk.DrawingArea da, Gdk.EventScroll es)
	{
		sw.grab_focus();

		switch(es.direction) {
		case ScrollDirection.UP:
			switch(wheel_action) {
			case WheelAction.PAN:
				codew.pany += 64;
				break;
			case WheelAction.ZOOM:
				codew.zoom += ZOOM_FACTOR;
				break;
			}
			break;
		case ScrollDirection.DOWN:
			switch(wheel_action) {
			case WheelAction.PAN:
				codew.pany -= 64;
				break;
			case WheelAction.ZOOM:
				codew.zoom -= ZOOM_FACTOR;
				break;
			}
			break;
		}

		da.queue_draw_area (0, 0, 5000, 2000);
		return false;
	}

	private bool key_release(Gtk.Widget w, Gdk.EventKey ek)
	{
		sw.grab_focus();

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

	private bool key_press (Gtk.Widget w, Gdk.EventKey ek)
	{
		bool handled = true;
		//DrawingArea da = (DrawingArea)w;
		sw.grab_focus();

		/* */
		stdout.printf("Key pressed %d (%c)\n", (int)ek.keyval, (int)ek.keyval);

		switch (ek.keyval) {
		default:
			handled = false;
			break;
		}

		//expose(da, ev);
		da.queue_draw_area(0,0,5000,2000);

		return true;
	}

	public void do_popup_generic()
	{
		ImageMenuItem imi;
 		menu = new Menu();

		/* XXX: most of this should be done in a tab panel or so */
		imi = new ImageMenuItem.from_stock("undo seek", null);
		imi.activate += imi => {
			/* foo */
			run_cmd("s-");
			load_codew_at("$$");
		};
		menu.append(imi);

		imi = new ImageMenuItem.from_stock("redo seek", null);
		imi.activate += imi => {
			/* foo */
			run_cmd("s+");
			load_codew_at("$$");
		};
		menu.append(imi);

		imi = new ImageMenuItem.from_stock("Seek to eip", null);
		imi.activate += imi => {
			/* foo */
			run_cmd("s eip");
			load_codew_at("$$");
		};
		menu.append(imi);

		menu.append(new SeparatorMenuItem());

		imi = new ImageMenuItem.from_stock("Step", null);
		imi.activate += imi => {
			/* foo */
			run_cmd("!step");
			run_cmd(".!regs*");
			load_codew_at("$$");
		};
		menu.append(imi);

		imi = new ImageMenuItem.from_stock("Continue", null);
		imi.activate += imi => {
			/* foo */
			run_cmd("!continue");
			run_cmd(".!regs*");
			load_codew_at("$$");
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
		return true;
	}

	// drag nodes
	private double opanx = 0;
	private double opany = 0;

	private double offx = 0;
	private double offy = 0;

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
		sw.grab_focus();
		/* pan view */
		if ((opanx!=0) && (opany!=0)) {
			double x = em.x-opanx;
			double y = em.y-opany;
	//		codew.panx+=x;//*0.8;
	//		codew.pany+=y;//*0.8;
			//codew.draw(Gdk.cairo_create(da.window));
			da.queue_draw_area(0, 0, 5000, 3000);
		}
		//Graph.selected = null;
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

	public void draw()
	{
		Context ctx = Gdk.cairo_create(da.window);
		codew.draw(ctx);
	}
}
