using Gtk;
using Radare;

static int main (string[] args) {
	if (args.length != 2)
		error ("Usage: %s <file>\n", args[0]);
	var bin = new RBin ();
	if (bin.load (args[1], false) != 1)
		error ("Cannot open binary file\n");
	Gtk.init (ref args);
	var w = new Window (WindowType.TOPLEVEL);
	w.title = "grabin";
	var grabin = new GrabinAll (bin);
	w.add (grabin);
	w.show_all ();
	Gtk.main ();
	return 0;
}
