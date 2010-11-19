using Gtk;
using Radare;

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

	public static const string VERSION = "0.1";
}

public static Ragui.GuiCore gc;
