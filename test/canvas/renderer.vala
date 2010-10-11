/* Interface cannot be used for the interface */
public abstract class Radare.CanvasApi.Renderer {
	/* must be generic */
	public abstract void square (double w, double h);
	public abstract void triangle (double w, double h, bool down);

	/* must be implemented in the base class */
	public abstract void begin (void *user);
	public abstract void end ();

	public abstract void user_to_device (ref double x, ref double y);
	public abstract void device_to_user (ref double x, ref double y);

	public abstract void save ();
	public abstract void restore ();

	public abstract void scale (double x, double y);
	public abstract void translate (double x, double y);
	public abstract void rotate (double angle);
	public abstract void move_to (double x, double y);

	public abstract void fill ();
	public abstract void stroke ();
	public abstract void set_color (Color c);

	public abstract void show_text (string name);
	public abstract void set_font (string name, int size, bool italic, bool bold);
}
