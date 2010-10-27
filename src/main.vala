/* ragui - copyright(C) 2009-2010 - pancake<nopcode.org> */

using Hexview;
using GLib;
using Gtk;

public class Ragui.Main {
	public static void quit_program () {
		stdout.printf("Thanks for watching :)\n");

		Gtk.main_quit();
	}

	public static void setup_leftbox (MainWindow mw) {
		var leftbox = mw.leftbox;
		leftbox.append_text ("Information");
		leftbox.append_text ("Functions");
		leftbox.append_text ("Imports");
		leftbox.append_text ("Exports");
		leftbox.append_text ("Libraries");
		leftbox.append_text ("Registers");
		leftbox.set_active (0);
		leftbox.changed.connect ( (x)=> {
			print ("I CAN HAZ CHANGES (%s)\n", x.get_active_text ());
			mw.leftvb.add (new Gtk.Label ("jejej"));
		});
	}

	public static void setup_io (MainWindow mw) {
		var hex = mw.hexview;
		hex.buffer.update.connect ((x,y)=> {
			print ("READING FROM 0x%08llx\n", x);
			uint8 *ptr = (void *)(size_t)x;
			hex.buffer.start = x;
			hex.buffer.end = x+y;
			hex.buffer.size = y;
			hex.buffer.bytes = new uint8[y];
			if (x>=0x8048000)
				Memory.copy (hex.buffer.bytes, ptr, y);
		});
	}

	public static int main (string[] args) {
		stdout.printf("Loading ragui...\n");

		Gtk.init(ref args);
		MainWindow mw = new MainWindow();
		//print ("==> %s\n", typeof (mw.leftbox));
		mw.on_quit.connect (quit_program);
		mw.resize(500, 400);
		mw.show_all();
		setup_leftbox (mw);
		setup_io (mw);
		Gtk.main();

		return 0;
	}
}
