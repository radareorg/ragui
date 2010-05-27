/* ragui - copyright(C) 2009 - pancake<nopcode.org> */

using Hexview;
using GLib;
using Gtk;

public class Ragui.Main
{
	public static void quit_program () {
		stdout.printf("Thanks for watching :)\n");

		Gtk.main_quit();
	}

	public static void setup_leftbox (ComboBox leftbox) {
		leftbox.append_text ("Information");
		leftbox.append_text ("Functions");
		leftbox.append_text ("Imports");
		leftbox.append_text ("Exports");
		leftbox.append_text ("Registers");
		leftbox.set_active (0);
		leftbox.changed.connect ( (x)=> {
			print ("I CAN HAZ CHANGES (%s)\n", x.get_active_text ());
		});
	}

	public static void setup_io (Hexview.Widget hex) {
		hex.buffer.update.connect ((x,y)=> {
			print ("READING FROM 0x%08llx\n", x);
			uint8 *ptr = (void *)x;
			hex.buffer.start = x;
			hex.buffer.end = x+y;
			hex.buffer.size = y;
			hex.buffer.bytes = new uint8[y];
			Memory.copy (hex.buffer.bytes, ptr, y);
		});
	}

	public static int main (string[] args) {
		stdout.printf("Loading ragui...\n");

		Gtk.init(ref args);
		MainWindow mw = new MainWindow();
//print ("==> %s\n", typeof (mw.leftbox));
		mw.on_quit += quit_program;
		mw.resize(500, 400);
		mw.show_all();
		setup_leftbox (mw.leftbox);
		setup_io (mw.hexview);
		Gtk.main();

		return 0;
	}
}
