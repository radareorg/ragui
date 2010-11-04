/* ragui - copyright(C) 2009-2010 - pancake<nopcode.org> */

using Hexview;
using GLib;
using Gtk;

GuiCore gc;

public class Ragui.Main {
	public static void quit_program () {
		stdout.printf("Thanks for watching :)\n");

		Gtk.main_quit();
	}

	public static void setup_leftbox (MainWindow mw) {
		var leftbox = mw.leftbox;
		leftbox.append_text ("Sections");
		leftbox.append_text ("Imports");
		leftbox.append_text ("Symbols");
		leftbox.append_text ("Relocations");
		leftbox.append_text ("Entry Points");
		leftbox.append_text ("Registers");
		leftbox.set_active (0);
		leftbox.changed.connect ( (x)=> {
			change_leftlist (mw, x.get_active_text ());
		});
		change_leftlist (mw, "Sections");
	}

	public static void setup_leftlist (MainWindow mw) {
		var lv = mw.listview;
		lv.set_actions ("seek", "breakpoint", "continue until", "inspect");
		lv.menu_handler.connect ((m, d) => {
			print ("clicked "+m.to_string ()+": "+
			d.name+"at addr"+d.offset.to_string ()+"\n");
		});
	}

	public static void change_leftlist (MainWindow mw, string type) {
		var lv = mw.listview;
		var baddr = gc.core.bin.get_baddr();
		lv.clear ();
		switch (type) {
			case "Sections":
				foreach (var scn in gc.core.bin.get_sections ())
					lv.add_row (baddr+scn.rva, scn.name);
				break;
			case "Imports":
				foreach (var imp in gc.core.bin.get_imports ())
					lv.add_row (baddr+imp.rva, imp.name);
				break;
			case "Symbols":
				foreach (var sym in gc.core.bin.get_symbols ())
					lv.add_row (baddr+sym.rva, sym.name);
				break;
			case "Relocations":
				foreach (var rel in gc.core.bin.get_relocs ())
					lv.add_row (baddr+rel.rva, rel.name);
				break;
			case "Entry Points":
				int i = 0;
				foreach (var entry in gc.core.bin.get_entries ()) {
					lv.add_row (baddr+entry.rva, "entry%i".printf (i++));
				}
				break;
			case "Registers":
				break;
		}
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
		Gtk.init(ref args);
		gc = new GuiCore ();
		gc.core.file_open ("/bin/ls", 0);
		gc.core.config.set ("io.va", "true");
		MainWindow mw = new MainWindow();
		//print ("==> %s\n", typeof (mw.leftbox));
		mw.on_quit.connect (quit_program);
		mw.resize(500, 400);
		mw.show_all();
		setup_leftbox (mw);
		setup_leftlist (mw);
		setup_io (mw);
		Gtk.main();

		return 0;
	}
}
