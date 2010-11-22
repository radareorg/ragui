using Gtk;
using Radare;

public static Ragui.GuiCore gc;
public static const string U64FMT = uint64.FORMAT_MODIFIER;

public class Ragui.GuiCore {
	public RCore core;
	public string arg0;
	public Window window;
	public bool debugger;

	public GuiCore (Window window, string arg0) {
		core = new RCore ();
		this.debugger = false;
		this.arg0 = arg0;
		this.window = window;
	}

	public void project_open (string file) {
		// open gtk dialog and so on.. 
	}

	public void project_save (string? file) {
		// open gtk dialog and so on.. 
	}

	public void project_close () {
		// open gtk dialog and so on.. 
	}

	public int cmd (string cmd) {
		int ret = gc.core.cmd0 (cmd);
		gc.core.cons.flush ();
		return ret;
	}

	public string cmdstr (string cmd) {
		return gc.core.cmd_str (cmd);
	}

	public bool seek (uint64 addr) {
		// XXX: handle ret value
		gc.core.seek (addr, true);
		cmd (@"s $addr");
		return true;
	}

// TODO: we need the MainWindow instance here..
	public bool show_yesno (string question) {
		MessageDialog md = new MessageDialog (window,
				DialogFlags.DESTROY_WITH_PARENT,
				MessageType.QUESTION, ButtonsType.YES_NO, question);
		int ret = md.run ();
		md.destroy ();
		return ret==ResponseType.YES;
	}

	public void show_message (string msg, MessageType mt) {
		MessageDialog md = new MessageDialog (window,
				DialogFlags.DESTROY_WITH_PARENT,
				mt, ButtonsType.CLOSE, msg);
		md.run ();
		md.destroy ();
	}

	public void show_error (string msg) {
		MessageDialog md = new MessageDialog (window,
				DialogFlags.DESTROY_WITH_PARENT,
				MessageType.ERROR,
				ButtonsType.CLOSE,
				msg);
		md.run ();
		md.destroy ();
	}

	public static const string VERSION = "0.1";
}
