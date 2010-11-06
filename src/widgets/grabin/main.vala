using Gtk;
using Radare;
using Grabin;

public void main (string[] args) {
	Gtk.init (ref args);

	var bin = new RBin ();
	bin.load ("/bin/ls", false);
	var w = new Window (WindowType.TOPLEVEL);
	w.title = "Grabin: Sections";
	var grabinsections = new Sections (bin);
	grabinsections.set_actions ("seek", "inspect");
	grabinsections.menu_handler.connect ((m, d) => {
		print ("clicked "+m+" -> "+d+"\n");
	});
	w.add (grabinsections);
	w.show_all ();

	Gtk.main ();
}
