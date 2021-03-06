using Gtk;
using Radare;

public static Ragui.GuiCore gc;
public static const string U64FMT = uint64.FORMAT_MODIFIER;
public static const string LOGFILE = "/tmp/r2log";

public enum Ragui.GuiCoreMode {
	EDIT,
	DIFF,
	DEBUG
}

public class Ragui.GuiCore {
	public RCore core;
	public RCore core2;
	public string arg0;
	public GuiCoreMode type;
	public Window window;
	public bool debugger;
	public string? prjfile = null;

	public GuiCore (Window window, string arg0) {
		core = new RCore ();
		this.debugger = false;
		this.arg0 = arg0;
		this.window = window;
		core.config.set ("asm.bytes", "false");
	}

	public void set_debugger(bool enable) {
		debugger = enable;
		if (debugger) {
			core.config.set ("cfg.debug", "true");
			core.config.set ("io.va", "false");
		} else {
			core.config.set ("cfg.debug", "false");
		}
	}

	public void project_open (string file) {
		// open gtk dialog and so on.. 
	}

	public void project_save (string? file) {
		prjfile = file;
		core.project_save (gc.prjfile);
		show_message ("Project "+gc.prjfile+" saved");
	}

	public void project_close () {
		// open gtk dialog and so on.. 
	}

	public int cmd (string cmd) {
		int ret = gc.core.cmd0 (cmd);
		Radare.RCons.flush ();
		return ret;
	}

	public bool bgtask { get; set; }

	private unowned Thread<void*> th;
	public int bgcmd (string cmd, string msg) {
		// TODO: BLOCK UI with a modal popup, closed when thread is joined
		try {
		//	unowned Thread<void*> 
			th = Thread.create <void*>( () => {
				bgtask = true;
				int ret = gc.core.cmd0 (cmd);
				Radare.RCons.flush ();
				return null;
			}, true);
			//unowned Thread th2 = 
			show_infprogress (msg);
			// TODO: capture this thread somewhere..
			Thread.create <void*> ( () => {
				th.join ();
				bgtask = true;
				Idle.add (() => {
					hide_infprogress ();
					show_message ("Task finished!\n");
					return false;
				});
				return null;
			}, true);

			//show_message ("Working in background.. wait a bit");
		} catch (ThreadError e) {
			show_error (e.message);
		}
		return 0; // XXX
	}

	public string cmdstr (string cmd) {
		return gc.core.cmd_str (cmd);
	}

	public bool seek (uint64 addr) {
		// XXX: handle ret value
		gc.core.seek (addr, true);
		gc.cmd (@"s $addr");
		return true;
	}

	public void open_url (string url) {
		// XXX: windows only
		system ("start "+url);

		// XXX: OSX only
		system ("open "+url);

		Pid pid;
		string[] runme = { "/usr/bin/xdg-open", url };
		try {
			if (!Process.spawn_async (null, runme, null,
					SpawnFlags.DO_NOT_REAP_CHILD, null, out pid))
				return;
		} catch (GLib.SpawnError err) {
			print ("Error: %s\n", err.message);
		}
/* This is the theorically portable way.. but it doesnt works
			try {
				var file = File.new_for_path ("http://www.radare.org/vdoc");
				var handler = file.query_default_handler (null);
				var list = new List<File> ();
				list.append (file);
				var result = handler.launch (list, null);
			} catch (GLib.Error err) {
				print ("Error: %s\n", err.message);
			}
*/
	}

	// TODO: rename show_ -> dialog_
	public bool dump (string file, string contents) {
		try {
			if (FileUtils.set_contents (file, contents))
				return true;
		} catch (FileError err) {
			return false;
		}
		return false;
	}

	public string? slurp (string file) {
		try {
			string data;
			if (FileUtils.get_contents (file, out data))
				return data;
		} catch (FileError err) {
			return null;
		}
		return null;
	}

	public string? show_file_save (string title, string? filepath) {
		var fcd = new FileChooserDialog (title, this.window, FileChooserAction.SAVE,
				"gtk-cancel", 0, "gtk-ok", 1);
		if (filepath != null)
			fcd.set_current_folder_uri (filepath);
		string? ret = null;
		if (fcd.run () == 1)
			ret = fcd.get_filename ();
		fcd.hide ();
		fcd.destroy ();
		fcd = null;
		return ret;
	}

	public string? show_file_open (string title, string? path = null) {
		var fcd = new FileChooserDialog (title, this.window, FileChooserAction.OPEN,
				"gtk-cancel", 0, "gtk-ok", 1);
		if (path != null)
			fcd.set_current_folder (path);
		string? ret = null;
		if (fcd.run () == 1)
			ret = fcd.get_filename ();
		fcd.hide ();
		fcd.destroy ();
		fcd = null;
		return ret;
	}

	public string? show_input (string question, string? txt = null) {
		var e = new Entry ();
		var md = new MessageDialog (window, DialogFlags.DESTROY_WITH_PARENT,
				MessageType.QUESTION, ButtonsType.YES_NO, question);
		var foo = (VBox)md.get_content_area ();
		if (txt != null)
			e.text = txt;
		foo.pack_start (e, false, false, 5);
		md.show_all ();
		var ret = md.run ();
		string? text = e.text;
		md.destroy ();
		if (ret == -9) // Why -9 means NO ? dunno .. but seems to works
			return null;
		print ("ret is %d\n", ret);
		return text;
	}

	public void show_text (string title, string txt) {
		var md = new MessageDialog (window, DialogFlags.DESTROY_WITH_PARENT,
				MessageType.INFO, ButtonsType.CLOSE, title);
		md.resizable = true;
		md.resize (600, 500);
		var foo = (VBox)md.get_content_area ();
		var sw = new ScrolledWindow (null, null);
                sw.set_policy (PolicyType.AUTOMATIC, PolicyType.AUTOMATIC);
		var tv = new TextView ();
                var couriertag = tv.buffer.create_tag ("cour", "family", "mono"); //, "weight", "bold");
		tv.editable = false;
		sw.add (tv);
		//tv.buffer.text = txt;
		TextIter ei;
                tv.buffer.get_start_iter (out ei);
		tv.buffer.insert_with_tags (ei, txt, -1, couriertag);
		foo.add (sw); //pack_start (sw, false, false, 5);
		md.show_all ();
		md.run ();
		md.destroy ();
	}

	public bool show_yesno (string question) {
		MessageDialog md = new MessageDialog (window,
				DialogFlags.DESTROY_WITH_PARENT,
				MessageType.QUESTION, ButtonsType.YES_NO, question);
		int ret = md.run ();
		md.destroy ();
		return ret==ResponseType.YES;
	}

	public void show_message (string msg, MessageType mt = Gtk.MessageType.INFO) {
		MessageDialog md = new MessageDialog (window,
				DialogFlags.DESTROY_WITH_PARENT,
				mt, ButtonsType.CLOSE, msg);
		md.run ();
		md.destroy ();
	}

	public void show_error (string msg) {
		MessageDialog md = new MessageDialog (window,
				DialogFlags.DESTROY_WITH_PARENT,
				MessageType.ERROR, ButtonsType.CLOSE, msg);
		md.run ();
		md.destroy ();
	}

	private Window ipw;
	private bool ipw_hide;

	public void hide_infprogress () {
		ipw.hide_all ();
		ipw = null;
		ipw_hide = true;
	}

	public void show_infprogress (string msg) {
		// TODO: handle on-window_close here... to stop gracefully..
		ipw = new Window ();
		ipw.window_position = WindowPosition.CENTER;
		ipw.modal = true;
		ipw.parent = window;
		var vb = new VBox (false, 6);
		vb.spacing = 10;
		vb.border_width = 10;
		var pb = new ProgressBar ();
		pb.pulse_fraction = 0.02;
		pb.bar_style = ProgressBarStyle.CONTINUOUS;
		ipw.add (vb);
		ipw_hide = false;
		Timeout.add (50, ()=> {
			if (ipw_hide)
				return false;
			pb.pulse ();
			return true;
		});
		vb.pack_start (new Label (msg), false, false, 3);
		vb.pack_start (pb, false, false, 8);
		ipw.show_all ();
	}

	public int system (string str) {
		return RSystem.cmd (str);
	}

	private int logcount = 0;
	public void log_file (string msg) {
		if (logcount++==0)
			FileUtils.unlink (LOGFILE);
		var fs = FileStream.open (LOGFILE, "a+");
		if (fs != null) {
			fs.puts (msg+"\n");
			fs = null;
		}
	}

	public static const string VERSION = "0.3b";

#if TEST
	static void main(string[] args) {
		Gtk.init (ref args);
		var gc = new GuiCore (new Window (WindowType.TOPLEVEL), args[0]);
	}
#endif
}
