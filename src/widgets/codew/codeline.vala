using GLib;
using Cairo;

public class Codewidget.Line
{
	public uint64 offset;
	public string hex;
	public string str;

	public void draw(Context ctx) {
		ctx.show_text("0x%08llx".printf(offset));

		ctx.move_to(20,0);
		ctx.show_text(hex);

		ctx.move_to(40,0);
		ctx.show_text(str);
	}
}
