using Cairo;

public class Radare.CanvasApi.RendererCairo : Renderer {
	public Context ctx;

	public override void begin (void *user) {
		Gdk.Drawable win = (Gdk.Drawable) user;
		ctx = Gdk.cairo_create (win);
		ctx.paint ();
		save ();
	}

	public override void user_to_device (ref double x, ref double y) {
		ctx.user_to_device (ref x, ref y);
	}

	public override void device_to_user (ref double x, ref double y) {
		ctx.device_to_user (ref x, ref y);
	}

	public override void end () {
		restore ();
	}

	public inline override void save () {
		ctx.save ();
	}

	public inline override void restore () {
		ctx.restore ();
	}

	public inline override void fill () {
		ctx.fill ();
	}

	public inline override void stroke () {
		ctx.stroke ();
	}

	public inline override void set_color (Color c) {
		ctx.set_source_rgb (c.r, c.g, c.b);
	}

	public inline override void show_text (string name) {
		ctx.show_text (name);
	}

	public inline override void set_font (string name, int size, bool italic, bool bold) {
		ctx.select_font_face (name,
			italic ? FontSlant.ITALIC : FontSlant.NORMAL,
			bold ? FontWeight.BOLD: FontWeight.BOLD);
		ctx.set_font_size (size);
	}

	public inline override void scale (double x, double y) {
		ctx.scale (x, y);
	}

	public inline override void translate (double x, double y) {
		ctx.translate (x, y);
	}

	public inline override void rotate (double angle) {
		ctx.rotate (angle);
	}

	public inline override void move_to (double x, double y) {
		ctx.move_to (x, y);
	}

	public override void square (double w, double h) {
		ctx.move_to (0, 0);
		ctx.rel_line_to (w, 0);
		ctx.rel_line_to (0, h);
		ctx.rel_line_to (-w, 0);
		ctx.close_path ();
	}

	public override void triangle (double w, double h, bool down) {
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
}
