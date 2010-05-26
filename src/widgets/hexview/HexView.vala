using Gtk;
using GLib;

namespace Radare.Widget {
	public class HexView : Gtk.VBox {
		private DrawingArea da;

		public HexView() {
			//pack_start(new Label ("foo"), false, false, 0);
			add (new Label ("foo"));
			da = new DrawingArea();	
			add (da);
		}
	}
}

void main(string[] args) {
	Gtk.init(ref args);
	var w = new Gtk.Window(WindowType.TOPLEVEL);
	var hex = new  Radare.Widget.HexView();
	hex.buffer.update.connect ((x,y)=> {
		print ("READING FROM 0x%08llx\n", x);
	});
	w.add (hex);
	w.show_all();
	Gtk.main();
}
