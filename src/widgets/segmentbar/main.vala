using Gtk;

public static void main (string[] args) {
	Gtk.init (ref args);

	var w = new Window ();
	
	var segbarHD = new SegmentedBar();

	segbarHD.BarHeight = 30; 
	segbarHD.HorizontalPadding = segbarHD.BarHeight / 2;
/*
	segbarHD.AddSegmentRgb ("/root", 0.15, 0xf57900);
	segbarHD.AddSegmentRgb ("/home", 0.80, 0x3465a4);
	segbarHD.AddSegmentRgb ("/swap", 0.05, 0x73d216);
*/
	segbarHD.AddSegmentRgb (".text", 0.15, 0xf57900);
	segbarHD.AddSegmentRgb (".data", 0.80, 0x3465a4);
	segbarHD.AddSegmentRgb (".got", 0.05, 0x73d216);
	segbarHD.ShowReflection = true;
	w.add (segbarHD);
	w.destroy.connect (Gtk.main_quit);
	w.show_all ();

	Gtk.main ();
}
