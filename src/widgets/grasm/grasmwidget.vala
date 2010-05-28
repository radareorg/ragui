/*
 *  Grasm - Graph assembler for radare2
 *  Copyright (C) 2009-2010  pancake <nopcode.org>
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
	private Entry inputasm_multi_hex;
	private Grava.Widget gw;
	private RAsm rasm;
	private static bool debug = false;

	private bool autogen = false;

	public Gtk.Widget get_widget() {
		return this;
	}

	construct {
		create_widgets ();
	}

	public void load_graph_at() {
		stdout.printf("funk!\n");
	}

	private string? o2b(string code) {
		if (code != "") {
			rasm.set_pc (inputoff.text.to_uint64 ());
			RAsm.Code? c = rasm.massemble (code);
			if (c != null) {
				if (debug)
					stdout.printf("BYTES(%s)\n", c.buf_hex);
				return (string)c.buf_hex;
			}
		}
		return null;
	}

	private void add_node() {
		if (o2b(inputasm.get_text()) != null) {
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
	}

	private string get_multi_str() {
		Gtk.TextIter tiend, tistart;
		inputasm_multi.buffer.get_start_iter(out tistart);
		inputasm_multi.buffer.get_end_iter(out tiend);
		return inputasm_multi.buffer.get_text (tiend, tistart, false);
	}

	private void add_node_multi() {
		string str = get_multi_str();
		if (o2b(str) == null) {
			Grava.Node *n = new Grava.Node ();
				n->set ("label", inputoff.get_text ());
				n->set ("color", "blue");
				n->set ("body", str);
			// TODO: inputasm.set_text("");
			//str = inputasm_multi.buffer.get_text (tiend, tistart, false);
			inputasm_multi.buffer = new TextBuffer (null); //tiend, tistart, false);
			gw.graph.add_node (n);
			gw.graph.update ();
			gw.draw ();
			generate_code ();
		}
	}

	private void generate_code() {
		outputbytes.text = "";
		string str = "";
		gw.graph.nodes.sort (
			/* TODO: bug vala here! can I cast the arguments directly? */
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
			} else {
				if (debug) stdout.printf("ASSEMBLE (%s)\n", body);
				str += o2b (body);
			}
		}
		outputbytes.text = str;
	}

	public string? disassemble(string hex) {
		RAsm.Aop aop;
		uint8 buffer[128];
		uint8 *ptr = (uint8*)buffer;
		int len = RHex.str2bin (hex, ptr);
		rasm.disassemble (out aop, ptr, len);
		return aop.buf_asm;
	}

	public void create_widgets () {
		rasm = new Radare.RAsm();
		rasm.use("x86.olly");
		rasm.set_syntax(RAsm.Syntax.INTEL);
		rasm.set_bits(32);
		rasm.set_big_endian(false);

		var hb0 = new HBox (false, 2);
		var vb0 = new VBox (false, 2);

			var hb = new HBox (false, 4);
				hb.pack_start (new Label ("Bytes:"), false, false, 2);
				outputbytes = new Entry ();
				outputbytes.editable = false;
				hb.add (outputbytes);

				ComboBox cb = new ComboBox.text ();
				cb.changed += (self) => {
					if (inputoff != null) {
						rasm.set_pc (inputoff.text.to_uint64 ());
						rasm.use(self.get_active_text ());
						inputasm.activate ();
					}
				};
				foreach (var p in rasm.plugins)
					cb.append_text (p.name);
				cb.set_active (0);
				rasm.use (cb.get_active_text ());
				hb.pack_start (cb, false, false, 4);

			vb0.pack_start (hb, false, false, 2);
			gw = new Grava.Widget();
			gw.graph.zoom = 2;
			gw.graph.update();
			gw.separator = 150;
			gw.load_graph_at.connect (load_graph_at);
			vb0.add (gw.get_widget ());
		hb0.add (vb0);

		VBox vb = new VBox(false, 4);
			hb = new HBox (false, 2);
				var agenbut = new CheckButton.with_label ("auto");
				agenbut.toggled.connect ( (x)=> {
					autogen = !autogen;
					if (autogen) {
						generate_code ();
						Timeout.add (512, () => {
							generate_code ();
							return autogen;
						} );
					}
				});
				hb.pack_start(agenbut, false, false, 2);
			vb.pack_start (hb, false, false, 2);

			var genbut = new Button.with_label ("Compile");
			genbut.clicked.connect ((v) => { generate_code(); });
			hb.add (genbut);

			inputoff = new Entry ();
				inputoff.activate.connect ((x) => {
					RAsm.Code? c = rasm.massemble (inputasm.get_text ());
					if (c != null)
						inputasm_hex.set_text (c.buf_hex);
				});
				inputoff.set_text ("0x8048000");
				vb.pack_start (inputoff, false, false, 1);
			inputasm = new Entry ();
				inputasm.set_text ("mov eax, 33");
				inputasm.activate.connect (add_node);
				inputasm.key_release_event += (foo) => {
					RAsm.Code? c = rasm.massemble (inputasm.get_text ());
					if (c != null)
						inputasm_hex.set_text (c.buf_hex);
					return false;
				};
				vb.pack_start(inputasm, false, false, 1);

			inputasm_hex = new Entry();
				inputasm_hex.activate.connect ((foo) => {
					var str = disassemble (inputasm_hex.get_text ());
					if (str != null)
						inputasm.set_text (str);
				});
			vb.pack_start (inputasm_hex, false, false, 1);

			var _hb = new HBox (false, 2);
				assemble = new Button.with_label ("add");
				assemble.clicked.connect ((x)=> {
					inputasm.activate ();
				});
				_hb.add (assemble);

				assemble = new Button.with_label ("dis");
				assemble.clicked.connect ((x)=> {
					inputasm_hex.activate ();
				});
				_hb.add (assemble);
			vb.pack_start (_hb, false, false, 4);

			var sw = new ScrolledWindow (null, null);
				sw.set_policy (PolicyType.AUTOMATIC, PolicyType.AUTOMATIC);
				inputasm_multi = new TextView ();
				inputasm_multi.key_release_event += (foo) => {
					RAsm.Code? c = rasm.massemble (get_multi_str ());
					if (c != null)
						inputasm_multi_hex.set_text (c.buf_hex);
					return false;
				};
				sw.add (inputasm_multi);
			vb.add (sw);

			inputasm_multi_hex = new Entry ();
			inputasm_multi_hex.editable = false;
			vb.pack_start (inputasm_multi_hex, false, false, 1);

			assemble = new Button.with_label ("Assemble");
			assemble.clicked.connect (add_node_multi);
			vb.pack_start (assemble, false, false, 1);
		vb.pack_start (hb, false, false, 2);

		hb0.pack_start (vb, false, false, 3);
		add (hb0);
	}
}
