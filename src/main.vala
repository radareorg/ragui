/* ragui - copyright(C) 2009 - pancake<nopcode.org> */

using GLib;
using Gtk;

public class Ragui.Main
{
	public static void quit_program()
	{
		stdout.printf("Thanks for watching :)\n");

		Gtk.main_quit();
	}

	public static int main(string[] args)
	{
		stdout.printf("Loading ragui...\n");

		Gtk.init(ref args);
		MainWindow mw = new MainWindow();
		mw.on_quit += quit_program;
		mw.resize(500, 400);
		mw.show_all();
		Gtk.main();

		return 0;
	}
}
