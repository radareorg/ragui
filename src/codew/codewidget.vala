using Cairo;

public class CodeWidget : GLib.Object {
	public double panx;
	public double pany;
	public double zoom;

	construct {
		panx = pany = 0;
		zoom = 0;
	}

	public void draw(Context ctx)
	{
//		ctx.set_operator (Cairo.Operator.SOURCE);
		// XXX THIS FLICKERS! MUST USE DOUBLE BUFFER
		if (ctx == null)
			return;

		ctx.set_source_rgba(1, 1, 1, 1);
		ctx.translate( panx, pany);
		ctx.scale( zoom, zoom );
	
		/* blank screen */
		ctx.paint();

		/* draw bg picture
		ctx.save();
		ctx.set_source_surface(s, panx, pany);
		ctx.paint();
		ctx.restore ();
		*/
		ctx.set_source_rgb (0.1, 0.1, 0.1);
		ctx.move_to(5, 10);
		ctx.show_text("Hello world");


		//foreach(weak Row row in rows) {
		//	Renderer.draw_edge(ctx, edge);
		//}
	}

	public void update()
	{
	}
}
