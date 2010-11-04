using Gtk;

public static int main (string[] args) {     
	Gtk.init (ref args);

	var w = new Window ();
	w.title = "treeview sample";

	var lw = new Listview.Widget ();

	lw.add_row (0x8048000, "main");
	lw.add_row (0x8048230, "wait");
	lw.add_row (0x8048480, "system");
	lw.add_row (0x8049350, "patata");

	lw.set_actions ("seek", "breakpoint", "continue until", "inspect");
	lw.menu_handler.connect ((m, d) => {
		print ("clicked "+m.to_string ()+": "+
			d.name+"at addr"+d.offset.to_string ()+"\n");
//		me.clear();
//		lw.add_row (0, "hello world");
	});

	w.add (lw);
	w.destroy.connect (Gtk.main_quit);

	w.show_all ();
	Gtk.main ();

	return 0;
}
