using Gtk;

public static void main (string[] args) {
	Gtk.init (ref args);
	var w = new Window (WindowType.TOPLEVEL);
	w.add (new Grarc ());
	w.show_all ();
	Gtk.main ();
}
