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
	var grabin = new Grabin.All (bin);
	grabin.sections.set_actions ("Seek");
	grabin.sections.menu_handler.connect ((m, d) => {
			print ("Sections clicked "+m+": "+d+"\n");
		});
	grabin.symbols.set_actions ("Seek");
	grabin.symbols.menu_handler.connect ((m, d) => {
			print ("Symbols clicked "+m.to_string ()+": "+d+"\n");
		});
	grabin.imports.set_actions ("Seek");
	grabin.imports.menu_handler.connect ((m, d) => {
			print ("Imports clicked "+m.to_string ()+": "+d+"\n");
		});
	grabin.strings.set_actions ("Seek");
	grabin.strings.set_retcolumn (Grabin.Strings.COLUMN.String);
	grabin.strings.menu_handler.connect ((m, d) => {
			print ("Strings clicked "+m.to_string ()+": "+d+"\n");
		});
	grabin.relocs.set_actions ("Seek");
	grabin.relocs.menu_handler.connect ((m, d) => {
			print ("Relocations clicked "+m.to_string ()+": "+d+"\n");
		});
	grabin.fat.set_actions ("Load", "Extract");
	grabin.fat.menu_handler.connect ((m, d) => {
			print ("SubBin clicked "+m.to_string ()+": "+d+"\n");
		});
	w.add (grabin);
	w.show_all ();
	Gtk.main ();
	return 0;
}
