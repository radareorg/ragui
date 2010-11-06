using Gtk;
using Radare;

public void main (string[] args) {
	Gtk.init (ref args);

	var bin = new RBin ();
	bin.load ("/bin/ls", false);
	var w = new Window (WindowType.TOPLEVEL);
	w.title = "Grabin: Sections";
	var grabinsections = new GrabinSections (bin);
	w.add (grabinsections);
	w.show_all ();

	Gtk.main ();
}
