/* ragui - copyright(C) 2009 - pancake<nopcode.org> */

using GLib;
using Gtk;

public class Ragui.Main
{
	public static int main(string[] args)
	{
		stdout.printf("Loading ragui...\n");

		Gtk.init(ref args);
		MainWindow mw = new MainWindow();
		mw.resize(500, 400);
		mw.show_all();
		Gtk.main();
		return 0;
	}
}
