using Cairo;

public class Radare.CanvasApi.Element : GLib.Object {
	public double ow;
	public double w;
	public double oh;
	public double h;
private Canvas c;

	public double ox;
	public double x;
	public double oy;
	public double y;

	public bool draggable;
	public bool is_ontop;
	public Animation animation;
	public Alignment alignment;
	public Color color;

	construct {
		draggable = true;
		is_ontop = false;
		alignment = Alignment ();
		animation = Animation.empty ();
	}

	public Element (double x, double y, double w, double h) {
		this.color = Color (0.2, 0.2, 0.4);
		move (x, y);
		resize (w, h);
	}

	public void scale (double x, double y) {
		this.w = this.ow * x;
		this.h = this.oh * y;
//		this.x = this.ox * x;
//		this.y = this.oy * y;
	}

	public void move (double x, double y) {
		this.x = this.ox = x;
		this.y = this.oy = y;
	}

	public void resize (double w, double h) {
		this.w = this.ow = w;
		this.h = this.oh = h;
	}

	public virtual void paint (Canvas c) {
	this.c = c;
		var r = c.render;
		r.set_color (this.color);
		r.square (this.w, this.h);
		r.fill ();

		r.set_color (Color (0.8, 0, 0));
		r.square (10, this.h);
		r.fill ();

		r.set_color (Color (0.8, 0.8, 0.8));
		r.stroke ();
	}

	public virtual bool activate (int button, double x, double y) {
		print ("==> Element activated %d\n", button);
/*
		Timeout.add (100, () => {
			this.y += 5;
			c.redraw ();
			if (this.y>300)
				return false;
			return true;
		});
*/
//		this.animation = Animation (
//			Vector (8, 15), Vector (0, -9), 1000);

		print (@"x = $(x)\n");
		if (x<10) {
			this.animation = Animation (
				Vector (-20, 0), Vector (0, 0), 1000);
		} else {
			this.animation = Animation (
				Vector (20, 0), Vector (0, 0), 1000);
		}
		Timeout.add (Animation.STEP_TIME, () => {
			bool re = this.animation.step ();
			this.x += this.animation.vector.x;
			this.y += this.animation.vector.y;
			// TODO: c.colide ()
			if (this.x <0) {
				this.x = 0;
				return false;
			}
			c.redraw ();
			return re;
		});
		return true;
	}

	public bool is_clicked (double x, double y) {
		return ((x>this.x && x<(this.x+this.w)) &&
			(y>this.y && y<(this.y+this.h)));
	}

	public bool overlaps (Element elem) {
		return (is_clicked (elem.x, elem.y) &&
			is_clicked (elem.x+elem.w, elem.y) &&
			is_clicked (elem.x+elem.w, elem.y+elem.h) &&
			is_clicked (elem.x, elem.y+elem.h));
	}
}
