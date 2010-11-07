using Radare;

public class Ragui.GuiCore {
	public RCore core;

	public GuiCore () {
		core = new RCore ();
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
}

public static Ragui.GuiCore gc;
