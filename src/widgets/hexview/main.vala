using Gtk;
using GLib;

void main(string[] args) {
	Gtk.init(ref args);
	var w = new Gtk.Window(WindowType.TOPLEVEL);
	w.add (new  Hexview.Widget());
	w.show_all();
	Gtk.main();
}
