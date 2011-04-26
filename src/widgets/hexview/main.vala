using Gtk;
using GLib;

void main(string[] args) {
	Gtk.init(ref args);
	var w = new Gtk.Window(WindowType.TOPLEVEL);
	var hex = new Hexview.Widget();
	hex.buffer.update.connect ((x,y)=> {
		uint8 *ptr = (void *)(size_t)x;
		hex.buffer.start = x;
		hex.buffer.end = x+y;
		hex.buffer.size = y;
		hex.buffer.bytes = new uint8[y];
		print ("READING FROM 0x%08llx (%p) = %d\n", x, ptr, y);
		for (int i=0; i<y; i++)
			hex.buffer.bytes[i] = (uint8)i;
		//if (x>=0x8048000)
		//	Memory.copy (hex.buffer.bytes, ptr, y);
		return true;
	});
	w.add (hex);

	w.resize (400, 300);
	w.show_all();
	Gtk.main();
}
