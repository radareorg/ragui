using Gtk;
using Radare.CanvasApi;

void fill_canvas (Canvas c) {
	var e = new Element (0, 0, 200, 100);
	c.add (e);

	var e2 = new Element (50, 105, 200, 100);
	e2.color = Color (0.4, 0.4, 0.4);
	c.add (e2);

	var b = new ButtonElement (100, 210, "Step");
	c.add (b);

	var b2 = new ButtonElement (100, 210, "Graph");
	b2.alignment.enabled = true;
	b2.alignment.type = Align.LEFT | Align.BOTTOM;
	b2.alignment.margin[Margin.BOTTOM] = 5;
	b2.alignment.margin[Margin.LEFT] = 5;
	c.add (b2);
}

void main (string[] args) {
	Gtk.init (ref args);
	var w = new Window (WindowType.TOPLEVEL);
	var canvas = new Canvas ();
	fill_canvas (canvas);
	canvas.color = null;
	//canvas.color = Color (0.1, 0.1, 0.1);
	canvas.scrollx = false;

	w.key_press_event += (w, e) => {
		switch (e.keyval) {
		case '+':
			canvas.zoom += 0.1;
			break;
		case '-':
			canvas.zoom -= 0.1;
			break;
		case '.':
			canvas.angle += 0.1;
			break;
		case ',':
			canvas.angle -= 0.1;
			break;
		}
		canvas.redraw ();
	};
	w.add (canvas);
	w.show_all ();
	w.destroy += (w) => {
		Gtk.main_quit ();
	};
	Gtk.main ();
}
