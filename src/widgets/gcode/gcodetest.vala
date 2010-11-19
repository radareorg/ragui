using Gtk;
using Radare;

static int main (string[] args) {
	Gtk.init (ref args);
	var w = new Window (WindowType.TOPLEVEL);
	w.title = "gcode";
	var gcode = new Gcode.Widget ();
	gcode.data_handler.connect ((x)=>{
			if (x)
				print ("I WANT MOAR DATA! (NEXT)\n");
			else
				print ("I WANT MOAR DATA! (PREV)\n");
		});
	gcode.set_text("a\na\na\na\na\na\na\na\na\na\na\na\na\na\na\na\na\na\na\na\na\na\na\na\na\na\na\na\na\na\na\na\na\na\na\na\na\na\na\na\na\na\na\na\na\na\na\na\na\na\na\na\na\na\na\na\na\na\na\na\na\na\na\na\na\na\na\na\na\na\na\na\na\na\na\na\na\na\na\na\na\na\na\na\na\na\na\na\na\na\na\n");
	w.add (gcode);
	w.show_all ();
	Gtk.main ();
	return 0;
}
