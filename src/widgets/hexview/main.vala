using Gtk;
using GLib;

void main(string[] args) {
	Gtk.init(ref args);
	var w = new Gtk.Window(WindowType.TOPLEVEL);
	var hex = new Hexview.Widget();
	hex.buffer.update.connect ((x,y)=> {
		print ("READING FROM 0x%08llx\n", x);
		uint8 *ptr = (void *)(size_t)x;
		hex.buffer.start = x;
		hex.buffer.end = x+y;
		hex.buffer.size = y;
		hex.buffer.bytes = new uint8[y];
		Memory.copy (hex.buffer.bytes, ptr, y);
	});
	w.add (hex);

	w.show_all();
	Gtk.main();
}
