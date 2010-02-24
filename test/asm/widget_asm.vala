/* radare - GPLv3 Copyright (C) pancake <at> nopcode.org
 * -----------------------------------------------------
 * To compile:
 *   valac --pkg gtk+-2.0 --pkg libr widget_asm.vala
 */

using GLib;
using Gtk;
using Radare;

public class widget 
{
	public static Entry easm;
	public static Entry ehex;
	public static Entry eoff;
	public static Asm st;
	public static Asm.Aop aop;

	public static void set_arch(string arch)
	{
		st.set(arch);
		st.set_bits(32);
		st.set_syntax(Asm.Syntax.INTEL);
		st.set_pc(0x8048000);
		st.set_big_endian(false);
		st.list();
	}

	public static Widget get_label_hbox(string label, Widget child)
	{
		var v = new HBox(false, 3);
		v.pack_start(new Label(label), false, false, 3);
		v.add(child);
		return v;
	}

	public static int main(string[] args)
	{
		Gtk.init(ref args);
		st = new Asm();

		set_arch("asm_x86_olly");

		/* test code */
		st.assemble(out widget.aop, "nop");
		stdout.printf("Nop is '%s'\n", widget.aop.buf_hex);

		var mw = new Window(WindowType.TOPLEVEL);
		mw.title = "libr based assembler/disassembler";
		mw.border_width = 5;
		mw.delete_event += () => {
			Gtk.main_quit();
		};

		widget.eoff = new Entry();
		widget.eoff.set_text("0x8048000");
		widget.eoff.key_release_event += (foo) => {
			uint8 [] buffer = new uint8 [64];
			string str = widget.eoff.get_text ();
			widget.st.set_pc(Util.num_get(null, str));

			str = widget.easm.get_text ();
			widget.st.assemble (out widget.aop, str);
			widget.ehex.set_text (widget.aop.buf_hex);
			return false;
		};

		VBox vb = new VBox(false, 5);
		widget.easm = new Entry();
		easm.key_release_event += (foo) => {
			string str = widget.easm.get_text ();
			widget.st.assemble (out widget.aop, str);
			widget.ehex.set_text (widget.aop.buf_hex);
			return false;
		};

		widget.ehex = new Entry();
		ehex.key_release_event += (foo) => {
			uint8* buffer = new uint8 [64];
			string str = widget.ehex.get_text ();
			int len = Util.hex_str2bin(str, out buffer);
			widget.st.disassemble (out widget.aop, buffer, len);
			widget.easm.set_text (widget.aop.buf_asm);
			return false;
		};

		ComboBox cb = new ComboBox.text();
		cb.changed += (self) => {
			string str = self.get_active_text();
			set_arch(str);
		};
		cb.insert_text(0, "asm_x86_olly");
		cb.insert_text(1, "asm_java");
		cb.insert_text(2, "asm_mips");
		cb.set_active(0);
		
		vb.pack_start(get_label_hbox("Architecture", cb), false, false, 3);
		vb.pack_start(get_label_hbox("Offset", eoff), false, false, 3);
		vb.pack_start(get_label_hbox("Opcode", easm), false, false, 3);
		vb.pack_start(get_label_hbox("Hexpairs", ehex), false, false, 3);

		var hbb = new HButtonBox();
		hbb.layout_style = ButtonBoxStyle.END;
		Button b = new Button.from_stock("gtk-ok");
		b.clicked += (foo) => {
			Gtk.main_quit();
		};
		hbb.pack_start(b, false, false, 3);
		vb.pack_end(hbb, false, false, 3);
		
		mw.add(vb);
		mw.show_all();
		Gtk.main();

		return 0;
	}
}
