using Gtk;

public static void main (string[] args) {
	Gtk.init (ref args);

	var w = new Window ();
	
	var segbarHD = new SegmentedBar();

#if 0
	segbarHD.BarHeight = 30; 
	segbarHD.HorizontalPadding = segbarHD.BarHeight / 2;
/*
	segbarHD.AddSegmentRgb ("/root", 0.15, 0xf57900);
	segbarHD.AddSegmentRgb ("/home", 0.80, 0x3465a4);
	segbarHD.AddSegmentRgb ("/swap", 0.05, 0x73d216);
*/
	segbarHD.AddSegmentRgb (".text", 0.15, 0xf57900);
	segbarHD.AddSegmentRgb (".data", 0.60, 0x3465a4);
	segbarHD.AddSegmentRgb (".got", 0.05, 0x73d216);
	segbarHD.AddSegmentRgb (".rodata", 0.25, 0x232286);
	segbarHD.ShowReflection = false;
#endif
	var vb = new VBox (false, 10);
	var cb = new ComboBox.text ();
	cb.append_text ("/bin/ls");
	cb.append_text ("maps");
	cb.append_text ("sections");
	//
	vb.pack_start (cb, false, false, 3);
	//vb.add(new Label("Memory map"));
	vb.add(segbarHD);
	// TODO: add disassembly and hexdump tabs
	w.add (vb);
	w.destroy.connect (Gtk.main_quit);
	w.show_all ();

	Gtk.main ();
}
