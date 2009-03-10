using GLib;
using Gtk;
using Radare;

public class widget 
{
	public static Entry easm;
	public static Entry ehex;
	public static Asm st;
	public static unowned Asm.Aop aop;

	public static int main(string[] args)
	{
		Gtk.init(ref args);
		st = new Asm();

		st.list();
		st.set("asm_x86_olly");
		st.set_bits(32);
		st.set_syntax(Asm.Syntax.INTEL);
		st.set_pc(0x8048000);
		st.set_big_endian(false);

		st.assemble(widget.aop, "nop");
		stdout.printf("Nop is '%s'\n", widget.aop.buf_hex);

		var mw = new Window(WindowType.TOPLEVEL);
		mw.delete_event += () => {Gtk.main_quit();};
		mw.title = "libr based assembler/disassembler";
		VBox vb = new VBox(false, 5);
		widget.easm = new Entry();
		easm.key_release_event += (foo) => {
			string str = widget.easm.get_text ();
			widget.st.assemble (widget.aop, str);
			widget.ehex.set_text (widget.aop.buf_hex);
			return false;
		};
		widget.ehex = new Entry();
		ehex.key_release_event += (foo) => {
			uint8 [] buffer = new uint8 [64];
			string str = widget.ehex.get_text ();
			int len = Util.hex_str2bin(str, buffer);
			widget.st.disassemble (widget.aop, buffer, len);
			widget.easm.set_text (widget.aop.buf_asm);
			return false;
		};
		vb.pack_start(easm, false, false, 3);
		vb.pack_start(ehex, false, false, 3);

		var hbb = new HButtonBox();
		hbb.layout_style = ButtonBoxStyle.END;
		hbb.pack_start(new Button.with_label("Ok"), false, false, 3);
		vb.pack_end(hbb, false, false, 3);
		
		mw.add(vb);
		mw.show_all();
		Gtk.main();
		return 0;
	}
}
