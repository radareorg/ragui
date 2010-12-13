using Gtk;
using Radare;

public static Ragui.GuiCore gc;
public static const string U64FMT = uint64.FORMAT_MODIFIER;

public enum Ragui.GuiCoreType {
	EDIT,
	DIFF,
	DEBUG
}

public class Ragui.GuiCore {
	public RCore core;
	public RCore core2;
	public string arg0;
	public GuiCoreType type;
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

	public bool bgtask = false;

	public int bgcmd (string cmd) {
		// TODO: BLOCK UI with a modal popup, closed when thread is joined
		try {
			unowned Thread<void*> th = Thread.create <void*>( () => {
				bgtask = true;
				int ret = gc.core.cmd0 (cmd);
				gc.core.cons.flush ();
				return null;
			}, true);
			//unowned Thread th2 = 
			// TODO: capture this thread somewhere..
			Thread.create <void> ( () => {
				th.join ();
				bgtask = true;
				Idle.add (() => {
					hide_infprogress ();
					show_message ("Task finished!\n");
					return false;
				});
			}, true);
			//show_message ("Working in background.. wait a bit");
			show_infprogress ("analyzing code..");
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

	public string show_input (string question) {
		var e = new Entry ();
		var md = new MessageDialog (window, DialogFlags.DESTROY_WITH_PARENT,
				MessageType.QUESTION, ButtonsType.YES_NO, question);
		var foo = (VBox)md.get_content_area ();
		foo.pack_start (e, false, false, 5);
		md.show_all ();
		var ret = md.run ();
		md.destroy ();
		return e.text;
	}

	public bool show_yesno (string question) {
		MessageDialog md = new MessageDialog (window,
				DialogFlags.DESTROY_WITH_PARENT,
				MessageType.QUESTION, ButtonsType.YES_NO, question);
		int ret = md.run ();
		md.destroy ();
		return ret==ResponseType.YES;
	}

	public void show_message (string msg, MessageType mt = MessageType.INFO) {
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

	private Window ipw;
	private bool ipw_hide;

	public void hide_infprogress () {
		ipw.hide_all ();
		ipw = null;
		ipw_hide = true;
	}

	public void show_infprogress (string msg) {
		// TODO: handle on-window_close here... to stop gracefully..
		ipw = new Window (WindowType.TOPLEVEL);
		ipw.modal = true;
		ipw.parent = window;
		var vb = new VBox (false, 5);
		var pb = new ProgressBar ();
		pb.pulse_fraction = 0.05;
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

	public static const string VERSION = "0.1";

	static void main(string[] args) {
		Gtk.init (ref args);
		var gc = new GuiCore (new Window (WindowType.TOPLEVEL), args[0]);
		gc.show_input ("jiji");
	}
}
