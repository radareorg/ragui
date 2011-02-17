/* ragui - copyright(C) 2009-2010 - pancake<nopcode.org> */

using Hexview;
using Ragui;
using GLib;
using Gtk;

public class Ragui.Main {
	public static void quit_program () {
		stdout.printf("Thanks for watching :)\n");

		Gtk.main_quit();
	}

	public static string script = "";
	public static bool norc = true;
	public static bool debugger = false;
	[CCode (array_length = false, array_null_terminated = true)]
	public static string[] files;

	static const OptionEntry[] options = {
		{ "debugger", 'd', 0, OptionArg.NONE, ref debugger, "Run in debugger mode", null },
		{ "norc", 'n', 0, OptionArg.NONE, ref norc, "Do not load RC file", null },
		{ "script", 's', 0, OptionArg.FILENAME, ref script, "Run script after loading file", "FILE" },
		{ "", 0, 0, OptionArg.FILENAME_ARRAY, ref files, null, "FILE..." },
		{ null }
	};

	public static void open_file (string uri, bool loadstuff) {
		if (loadstuff) {
			// analyze code
			// load symbols, imports, ...
		}
		gc.core.file_open (uri, 0, 0);
		if (gc.core.file != null) {
			gc.core.bin_load (null);
			gc.core.config.set ("io.va", "true");
			gc.core.config.set ("scr.color", "false");
			mw.view_body ();
		}
	}

	private static MainWindow mw;

	public static int main (string[] args) {
		try {
			var opt_context = new OptionContext ("ragui");
			opt_context.set_help_enabled (true);
			opt_context.add_main_entries (options, null);
			opt_context.parse (ref args);
		} catch (OptionError e) {
			print ("%s\n", e.message);
			print ("Run '%s --help' to see a full list of available command line options.\n", args[0]);
			return 1;
		}

		Gtk.init (ref args);
		mw = new MainWindow ();
		gc = new GuiCore (mw, args[0]);
		gc.core.config.set ("io.va", "true");
		gc.core.config.set ("scr.color", "false");
		gc.core.config.set ("asm.stackptr", "false");
		gc.debugger = debugger; // set gui mode in debugger mode
		if (files != null) {
			gc.core.file_open (files[0], 0, 0);
			if (gc.core.file != null) {
				gc.core.bin_load (null);
				mw.view_body ();
				mw.title = "ragui : %s".printf (files[0]);
			} else {
				gc.show_error ("Cannot open file");
				mw.view_panel ();
			}
		} else mw.view_panel ();

		if (mw.panel != null) {
			mw.panel.open_file.connect ( (file) => {
				mw.title = @"ragui : $file";
				gc.core.file_open (file, 0, 0);
				if (gc.core.file != null) {
					gc.core.bin_load (null);
					gc.core.config.set ("io.va", "true");
					gc.core.config.set ("scr.color", "false");
					mw.view_body ();
					return true; // XXX: must check if open fails or what
				}
				return false;
			});
			mw.panel.onHelpAbout.connect ( () => {
				mw.OnMenuHelpAbout ();
			});
			mw.panel.onHelpAPI.connect ( () => {
				mw.OnMenuHelpAPI ();
			});
		}
		//print ("==> %s\n", typeof (mw.leftbox));
		mw.on_quit.connect (quit_program);
		mw.resize (800, 600);
		mw.show_all ();
		mw.setup_view ();
		Gtk.main ();

		return 0;
	}
}
