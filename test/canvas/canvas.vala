using Gtk;
using Gdk;
using Radare.CanvasApi;

public class Radare.CanvasApi.Canvas : DrawingArea {
	public Renderer render;
	public List<Element> elements;
	public Element? selected;
	public double panx;
	public double pany;
	public double angle;
	public double zoom;
	public int w;
	public int h;
	public Color? color;
	public double lastx;
	public double lasty;
	public double lastex;
	public double lastey;

	public bool scrollx;
	public bool scrolly;

	private bool first = true;

	construct {
		color = Color (1, 1, 1);
		render = new RendererCairo ();
		elements = new List<Element> ();
		zoom = 1.0;
		panx = pany = 0.0;
		angle = 0.0;
		scrollx = scrolly = true; // limit scrolling
	}

	public void device_to_user (ref double x, ref double y, bool do_angle = true) {
		/* This is inefficient */
		render.save ();
		render.translate (panx, pany);
		if (do_angle)
			render.rotate (angle);
		render.scale (zoom, zoom);
		render.device_to_user (ref x, ref y);
		render.restore ();
	}

	public Canvas () {
		this.add_events (
			Gdk.EventMask.BUTTON1_MOTION_MASK |
			Gdk.EventMask.SCROLL_MASK         |
			Gdk.EventMask.ENTER_NOTIFY_MASK   |
			Gdk.EventMask.KEY_PRESS_MASK      |
			Gdk.EventMask.KEY_RELEASE_MASK    |
			Gdk.EventMask.BUTTON_PRESS_MASK   |
			Gdk.EventMask.BUTTON_RELEASE_MASK );

		this.button_press_event += (d, e) => {
			double x = e.x;
			double y = e.y;
			double rx = e.x;
			double ry = e.y;

			device_to_user (ref rx, ref ry, true); // rotated xy
			device_to_user (ref x, ref y, false); // normal xy

			first = true;
			do_click ((int)e.button, x, y, rx, ry, false);
			{
				/* zoom hack for nonwheel mouses */
				if (e.button == 2)
					zoom += 0.1;
				else 
				if (e.button == 3)
					zoom -= 0.1;
			}
			redraw ();
		};

		this.button_release_event += (d, e) => {
			double x = e.x;
			double y = e.y;
			double rx = e.x;
			double ry = e.y;

			device_to_user (ref rx, ref ry, true); // rotated xy
			device_to_user (ref x, ref y, false); // normal xy

//print ("FIRST = %s\n", first.to_string ());
			if (first)
				do_click ((int)e.button, x, y, rx, ry, true);
			redraw ();
		};

		this.motion_notify_event += (d, e) => {
			double x = e.x;
			double y = e.y;

			device_to_user (ref x, ref y);

			if (first) { // ugly
				first = false;
			} else {
				if (selected == null) {
					if (this.scrollx)
						panx += (e.x-lastex);
					if (this.scrolly)
						pany += (e.y-lastey);
				} else {
					if (selected.draggable) {
						selected.x += (x-lastx);//(e.x-lastx)*zoom;
						selected.y += (y-lasty); //(e.y-lasty)*zoom;
					}
				}
				print (@"PANX = $(panx)  PANY = $(pany)\n");
			}
			lastex = e.x;
			lastey = e.y;
			lastx = x;
			lasty = y;
			redraw ();
		};

		this.scroll_event += (d, e) => {
			print ("Scroll\n");
			switch (e.direction) {
			case ScrollDirection.UP:
				zoom += 0.1;
				break;
			case ScrollDirection.DOWN:
				zoom -= 0.1;
				break;
			}
			print (@"zoom $(zoom)\n");
			redraw ();
		};

		this.expose_event += (d, e) => {
			this.window.get_size (out this.w, out this.h);
			//print (@"Expose $(this.w) $(this.h)\n");
			paint_all ();
		};
	}

	public bool do_click (int button, double x, double y, double rx, double ry, bool foo = false) {
		selected = null;
		// TODO: implement foreach_prev in a cleaner way ???
		weak List<Element>? iter = elements.last ();
		while (iter != null) {
print ("oo2\n");
			var elem = iter.data;
print ("oo3\n");
			bool clicked = false;
print ("oo4\n");
if (elem == null)
	break;
			if (elem.alignment.enabled)
				clicked = elem.is_clicked (x, y);
			else clicked = elem.is_clicked (rx, ry);
print ("oo5\n");
			if (clicked) {
				selected = elem;
				raise (selected); // raise on click
				if (foo && elem.activate (button, rx-elem.x, ry-elem.y))
					return true;
			}
			iter = iter.prev;
		}
		return false;
	}

	public void paint_element (Element elem) {
		render.save ();
		if (elem.alignment.enabled)
			render.rotate (-angle);
		render.translate (elem.x, elem.y);
		elem.paint (this);
		render.restore ();
	}

	public void redraw () {
		this.queue_draw_area (0, 0, this.w, this.h);
	}

	private void realign_xy () {
		foreach (var e in elements) {
			var align = e.alignment;
			if (!align.enabled)
				continue;
			//Element? eref = e.align_ref;
			if ((align.type & Align.LEFT) != 0) {
				e.x = (-panx+align.margin[Margin.LEFT]*zoom)/zoom;
			}
			if ((align.type & Align.RIGHT) != 0) {
				e.x = ((w-panx-(e.w*zoom)-(align.margin[Margin.RIGHT]*zoom))/zoom);
			}
			if ((align.type & Align.TOP) != 0) {
				e.y = ((align.margin[Margin.TOP]*zoom)-pany)/zoom;
			}
			if ((align.type & Align.BOTTOM) != 0) {
				e.y = ((h-pany-(e.h*zoom)-(align.margin[Margin.BOTTOM]*zoom))/zoom);
			}

			if ((align.type & Align.LEFT) != 0 && (align.type & Align.RIGHT) != 0) {
				// realign width
			}

			if ((align.type & Align.TOP) != 0 && (align.type & Align.BOTTOM) != 0) {
				// realign height
			}
		}
	}

	private void raise_single (Element elem) {
		elements.remove (elem);
		elements.append (elem);
	}

	private void realign_z () {
		foreach (var e in elements) {
			if (e.is_ontop)
				raise_single (e);
		}
	}

	public void raise (Element elem) {
		raise_single (elem);
		realign_z ();
	}

	public void lower (Element elem) {
		elements.remove (elem);
		elements.prepend (elem);
		realign_z ();
	}

	public void paint_all () {
		realign_xy ();
		render.begin (this.window);

		/* set background color */
		if (color != null) {
			render.set_color (color);
			render.square (this.w, this.h);
			render.fill ();
		}

		/* scene matrix transformation */
		render.translate (panx, pany);
		render.rotate (angle);
		render.scale (zoom, zoom);

		/* paint all elements in scene */
		foreach (var elem in elements) {
			paint_element (elem);
		}
		render.end ();
	}

	public void add (Element elem) {
		elements.append (elem);
	}

	public void del (Element elem) {
		elements.remove (elem);
	}
}
