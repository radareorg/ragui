/*
 *  Grasm - Graph assembler for radare2
 *  Copyright (C) 2009  pancake <youterm.com>
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
	private Grava.Widget gw;
	private Radare.Asm rasm;

	public Gtk.Widget get_widget()
	{
		return this;
	}

	construct {
		create_widgets ();
	}

	public void load_graph_at()
	{
		stdout.printf("funk!\n");
	}

	private void add_node()
	{
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

	private void generate_code()
	{
	/* XXX: sort by Y */
	/* XXX: ignore nodes in X<separator */
		Asm.Aop op;
		outputbytes.set_text("");
		string str="";
		foreach(weak Grava.Node node in gw.graph.nodes) {
			string code = node.get("body");
			if (rasm.massemble(out op, code) <1) {
				stderr.printf("error\n");
			} else {
				str += op.buf_hex;
			}
		}
		outputbytes.set_text(str);
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
/*
		Grava.Node *n = new Grava.Node();
			n->set("label", "cow");
			n->set("color", "blue");
			n->set("body", "hello world");
			gw.graph.add_node(n);
*/

		gw.graph.update();
		gw.separator = 150;
		gw.load_graph_at.connect(load_graph_at);
		hb0.add (gw.get_widget());
		VBox vb = new VBox(false, 4);
			vb.pack_start(new Label("Offset:"), false, false, 4);
			inputoff = new Entry();
			inputoff.set_text("0x8048000");
			vb.pack_start(inputoff, false, false, 4);
			vb.pack_start(new Label("Opcode"), false, false, 4);
			inputasm = new Entry();
			inputasm.activate.connect(add_node);
			vb.pack_start(inputasm, false, false, 4);
			assemble = new Button.with_label("Assemble");
			assemble.clicked.connect(add_node);
			vb.pack_start(assemble, false, false, 4);
			hb0.pack_start(vb, false, false, 3);
		add(hb0);
		var hb = new HBox(false, 2);
		hb.pack_start(new Label("Output bytes:"), false, false, 2);
		outputbytes = new Entry();
		hb.add(outputbytes);
		pack_start(hb, false, false, 4);
	}
}
