using Cairo;
using Radare.CanvasApi;

public class Radare.CanvasApi.ButtonElement : Element {
	private string label;
	private Canvas c;

	public ButtonElement (int x, int y, string label) {
		base (x, y, 100, 30);

		this.label = label;
		this.draggable = false;
		this.is_ontop = true;
		this.alignment.enabled = true;
		this.alignment.type = Align.BOTTOM | Align.RIGHT;
		this.alignment.margin[Margin.BOTTOM] = 5;
		this.alignment.margin[Margin.RIGHT] = 5;
		this.color = Color (0.3, 0.3, 0.3);
	}

	public override void paint (Canvas c) {
		this.c = c;
		var r = c.render;

		r.set_color (this.color);
		r.square (w, h);
		r.fill ();

		r.set_color (Color (1, 0, 1));
		r.set_font ("Sans Serif", 10, false, true);
		r.save ();
		r.translate (10, 20);
		r.show_text (this.label);
		r.restore ();

		r.set_color (Color (0.2, 0.2, 0.2));
		r.stroke ();
	}

	public override bool activate (int button, double x, double y) {
		this.color = Color (0.8, 0.8, 0.8);
		Timeout.add (100, () => {
			this.color = Color (0.3, 0.3, 0.3);
			c.redraw ();
			return false;
		});
		return true;
	}
}
