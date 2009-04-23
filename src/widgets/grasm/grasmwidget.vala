/*
 *  Grasm - Graph assembler for radare2
 *  Copyright (C) 2009  pancake <nopcode.org>
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

using Radare;
using Grava;
using GLib;
using Gtk;

public class Grasmwidget.Widget : VBox { 

	private Button assemble;
	private Entry outputbytes;
	private Entry inputoff;
	private Entry inputasm;
	private TextView inputasm_multi;
	private Entry inputasm_hex;
	private Grava.Widget gw;
	private Radare.Asm rasm;
	private Asm.Aop op;
	private static bool debug = false;

	public Gtk.Widget get_widget()
	{
		return this;
	}

	construct
	{
		create_widgets ();
	}

	public void load_graph_at()
	{
		stdout.printf("funk!\n");
	}

	private void error(string msg)
	{
		var d = new Gtk.Dialog();
		d.title = "grasm error";
		d.modal = true;
		d.add_button("gtk-ok", 0);
		d.vbox.add(new Label(msg));
		d.run();
		d.destroy();
		d = null;
	}

	private string? o2b(string code)
	{
		string b;
		if (code == "")
			return null;
		rasm.set_pc(0x8048000);
		if (rasm.massemble(out op, code) <1) {
			error("Invalid opcode");
			return null;
		}
		b = op.buf_hex;
		if (debug) stdout.printf("BYTES(%s)\n", b);
		return b;
	}

	private void add_node()
	{
		if (o2b(inputasm.get_text()) == null) {
			error("Cannot assemble this opcode");
			return;
		}

		Grava.Node *n = new Grava.Node();
			n->set("label", inputoff.get_text());
			n->set("color", "blue");
			n->set("body", inputasm.get_text());
		inputasm.set_text("");
		gw.graph.add_node(n);
		gw.graph.update();
		gw.draw();
		generate_code();
	}

	private void add_node_multi()
	{
		string str;
		Gtk.TextIter tiend, tistart;
		inputasm_multi.buffer.get_start_iter(out tistart);
		inputasm_multi.buffer.get_end_iter(out tiend);
		str = inputasm_multi.buffer.get_text (tiend, tistart, false);
		if (o2b(str) == null) {
			error("Cannot assemble this opcode");
			return;
		}

		Grava.Node *n = new Grava.Node();
			n->set("label", inputoff.get_text());
			n->set("color", "blue");
			n->set("body", inputasm.get_text());
		// TODO: inputasm.set_text("");
		str = inputasm_multi.buffer.get_text (tiend, tistart, false);
		gw.graph.add_node(n);
		gw.graph.update();
		gw.draw();
		generate_code();
	}

	private void generate_code()
	{
		outputbytes.text = "";
		string str = "";
		gw.graph.nodes.sort(
			/* TODO: can I cast the arguments directly? */
			(a,b) => {
				Grava.Node *na = a;
				Grava.Node *nb = b;
				return (int)(na->y - nb->y);
			}
		);
		/* TODO: Change color of node depending on ignored or not */
		foreach(weak Grava.Node node in gw.graph.nodes) {
			double posx = (node.x+gw.graph.panx)*gw.graph.zoom;
			string body = node.get("body");
			if (posx < 100) {
				if (debug) stdout.printf("IGNORE (%s)\n", body);
				//node.set("color", "gray");
			} else {
				if (debug) stdout.printf("ASSEMBLE (%s)\n", body);
				str += o2b(body);
				//node.set("color", "blue");
			}
		}
		outputbytes.text = str;
		//gw.draw();
	}

	public void create_widgets ()
	{
		rasm = new Radare.Asm();
		rasm.set("asm_x86_olly");
		rasm.set_syntax(Asm.Syntax.INTEL);
		rasm.set_bits(32);
		rasm.set_big_endian(false);

		gw = new Grava.Widget();
		var hb0 = new HBox(false, 2);
		gw.graph.zoom = 2;
		gw.graph.update();
		gw.separator = 150;
		gw.load_graph_at.connect(load_graph_at);
		hb0.add (gw.get_widget());
		VBox vb = new VBox(false, 4);
			ComboBox cb = new ComboBox.text();
			cb.changed += (self) => {
				string str = self.get_active_text();
				rasm.set(str);
			};
			cb.insert_text(0, "asm_x86_olly");
			cb.insert_text(1, "asm_java");
			cb.insert_text(2, "asm_mips");
			cb.set_active(0);

			vb.pack_start(cb, false, false, 4);
			vb.pack_start(new Label("Offset:"), false, false, 4);
			inputoff = new Entry();
			inputoff.set_text("0x8048000");
			vb.pack_start(inputoff, false, false, 4);
			vb.pack_start(new Label("Opcode"), false, false, 4);
			inputasm = new Entry();
			inputasm.activate.connect(add_node);
			inputasm.key_release_event += (foo) => {
				Radare.Asm.Aop aop;
				string str = inputasm.get_text ();
				rasm.assemble (out aop, str);
				inputasm_hex.set_text (aop.buf_hex);
				return false;
			};
			vb.pack_start(inputasm, false, false, 4);
			assemble = new Button.with_label("Assemble");
			assemble.clicked.connect(add_node);
			vb.pack_start(assemble, false, false, 4);
			vb.pack_start(new HSeparator(), false, false, 4);

			var sw = new ScrolledWindow(null, null);
			sw.set_policy(PolicyType.AUTOMATIC, PolicyType.AUTOMATIC);
			inputasm_multi = new TextView();
			//inputasm_multi..connect(add_node_multi); // +=( (foo)=> {add_node_multi(); });
			sw.add(inputasm_multi);
			vb.pack_start(sw, false, false, 4);

			inputasm_hex = new Entry();
			inputasm_hex.editable = false;
			vb.pack_start(inputasm_hex, false, false, 4);

			assemble = new Button.with_label("Assemble");
			assemble.clicked.connect(add_node_multi);
			vb.pack_start(assemble, false, false, 4);
			hb0.pack_start(vb, false, false, 3);
		add(hb0);
		var hb = new HBox(false, 2);
		hb.pack_start(new Label("Output bytes:"), false, false, 2);
		outputbytes = new Entry();
		outputbytes.editable = false;
		hb.add(outputbytes);
		var genbut = new Button.with_label("Compile");
		genbut.clicked.connect( (v)=>{ generate_code(); } );
		hb.pack_start(genbut, false, false, 2);
		pack_start(hb, false, false, 4);

		/* XXX: Quick hack to not modify dramatically grava */
		Timeout.add (512, () => {
			generate_code();
			return true;
		} );
	}
}
