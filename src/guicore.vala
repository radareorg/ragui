using Radare;

public class Ragui.GuiCore {
	public RCore core;
	public string arg0;

	public GuiCore (string arg0) {
		core = new RCore ();
		this.arg0 = arg0;
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

	public static const string VERSION = "0.1";
}

public static Ragui.GuiCore gc;
