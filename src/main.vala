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
		leftbox.append_text ("Information");
		leftbox.append_text ("Sections");
		leftbox.append_text ("Imports");
		leftbox.append_text ("Symbols");
		leftbox.append_text ("Relocations");
		leftbox.append_text ("Entry Points");
		leftbox.append_text ("Registers");
		leftbox.append_text ("Breakpoints");
		leftbox.set_active (1);
		leftbox.changed.connect ( (x)=> {
			change_leftlist (mw, x.get_active_text ());
		});
		change_leftlist (mw, "Sections");
	}

	public static void setup_leftlist (MainWindow mw) {
		var lv = mw.listview;
		// TODO:get leftbox option
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
		lv.show ();
		mw.vb0.show_all ();
		mw.vb1.hide ();
		switch (type) {
			case "Information":
				var info = gc.core.bin.get_info ();
				mw.itype.label = info.type;
				mw.os.label = info.os;
				mw.arch.label = info.arch;
				mw.machine.label = info.machine;
				mw.subsystem.label = info.subsystem;
				mw.bits.label = info.bits.to_string ();
				mw.endian.label = info.big_endian?"big":"little";
				mw.vb0.hide ();
				mw.vb1.show_all ();
				lv.hide ();
				break;
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

	public static void setup_console (MainWindow mw) {
		var cons = mw.console;

		cons.cmd_handler.connect ((x) => {
			var prompt = ("[0x%08"+uint64.FORMAT_MODIFIER+"x] ").printf (gc.core.offset);
			var cmd = gc.core.cmd_str (x);
			cons.set_text (prompt+x+"\n"+cmd);
		});
	}

	public static string script = "";
	public static bool runrc = true;

	static const OptionEntry[] options = {
		{ "norc", 'n', 0, OptionArg.NONE, ref script, "Do not load RC file", null },
		{ "script", 's', 0, OptionArg.FILENAME, ref script, "Run script after loading file", "FILE" },
		{ null }
	};

	public static int main (string[] args) {

		try {
			var opt_context = new OptionContext ("ragui");
			opt_context.set_help_enabled (true);
			opt_context.add_main_entries (options, null);
			opt_context.parse (ref args);
		} catch (OptionError e) {
			stdout.printf ("%s\n", e.message);
			stdout.printf ("Run '%s --help' to see a full list of available command line options.\n", args[0]);
			return 1;
		}

		Gtk.init(ref args);
		gc = new GuiCore ();
		gc.core.file_open ("/bin/ls", 0);
		gc.core.config.set ("io.va", "true");
		gc.core.config.set ("scr.color", "false");
		MainWindow mw = new MainWindow();
		//print ("==> %s\n", typeof (mw.leftbox));
		mw.on_quit.connect (quit_program);
		mw.resize(500, 400);
		mw.show_all();
		setup_leftbox (mw);
		setup_leftlist (mw);
		setup_io (mw);
		setup_console (mw);
		Gtk.main();

		return 0;
	}
}
