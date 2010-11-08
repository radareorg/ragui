using GLib;
using Grava;
//using Grava.Graph;

[Compact]
public static class Grava.Dot {
	public static bool import (Graph gr, string file) {
		return false;
	}
}

[Compact]
public static class Grava.XDot {
	private static bool parse_node(string node, out string node1) {
		char *str = node.chr (-1, '"');
		if (str == null)
			return false;
		node1 = (string)(str+1);
		str = node1.chr (-1, '"');
		if (str == null)
			return false;
		str[0] = '\0';
		return true;
	}

	private static bool parse_pos(string str, out int x, out int y) {
		// XXX swap x, y?
		if (str.scanf ("%d,%d", out x, out y) != 2)
			return false;
		return true;
	}

	private static bool parse_edge(string node, out string node1, out string node2) {
		char *str = node.chr (-1, '"');
		if (str == null)
			return false;
		node1 = (string)(str+1);
		str = node1.chr (-1, '"');
		if (str == null)
			return false;
		str[0] = '\0';
	
		node2 = (string)(str+1);
		str = node2.chr (-1, '"');
		if (str == null)
			return false;
		node2 = (string)(str+1);
		str = node2.chr (-1, '"');
		if (str == null)
			return false;
		str[0] = '\0';
		return true;
	}

	private static Node get_node (Graph gr, string label) {
		Node? n = gr.get_node ("label", label);
		if (n == null) {
			n = new Node ();
			n.set ("label", label);
			n.fit ();
			gr.add_node (n);
		}
		return n;
	}

	private static bool import_line (Graph gr, string row) {
		Edge? e = null;
		Node? n = null;
		if (row[0] == '\t' && row[1] == '"') {
			char *ptr = row.chr (-1, '[');
			if (ptr != null) {
				ptr[0] = '\0';
				if (row.str ("->") != null) {
					string node1, node2;
					if (parse_edge (row, out node1, out node2)) {
						print ("EDGE '%s' -> '%s'\n", node1, node2);
						Node n1 = get_node (gr, node1);
						Node n2 = get_node (gr, node2);
						e = new Edge (n1, n2);
						gr.add_edge (e);
						n = null;
					} else stderr.printf ("Error parsing edge\n");
				} else {
					string node;
					if (parse_node (row, out node)) {
						n = get_node (gr, node);
						print ("NODE '%s'\n", node);
					} else stderr.printf ("Error parsing node\n");
				}

				// XXX HACK
				string directive = ((string)(ptr+1)).replace (", pos=", "\", pos=");
				var foo = directive.split ("\", ");
				foreach (var field in foo) {
					if (field.has_prefix ("pos=\"")) {
						string pos = field[5:-1];
						*ptr = '\0';
						char ch = (char)pos[0];
						if (ch>='0' && ch<='9') {
							int x, y;
							if (parse_pos (pos, out x, out y)) {
								if (n != null) {
									n.x = x;
									n.y = y;
									print (" - pos: %d %d\n", x, y);
								} else stderr.printf ("POS: uhm no node?\n");
							} else stderr.printf ("Error parsing node\n");
						}
						break;
					} else
					if (field.has_prefix ("label=\"")) {
						weak string str = (string?)((char*)field+7);
						string label = str.replace ("\\l", "\n");
						print ("LABEL(%s)\n", label);
						if (n != null) {
							n.set ("body", label);
							n.fit ();
						} else stderr.printf ("uhm no node?\n");
					} else
					if (field.has_prefix ("color=")) {
						string color;
						weak string str;
						if (field[7] == '"') {
							str = (string?)((char*)field+7);
							color = str.replace ("\\l", "\n");
							char *bar = color.chr (-1, '"');
							if (bar != null)
								bar[0]='\0';
						} else {
							str = (string?)((char*)field+6);
							color = str.replace ("\\l", "\n");
							char *bar = color.chr (-1, ',');
							if (bar != null)
								bar[0]='\0';
						}
						print ("COLOR(%s)\n", color);
						if (n != null) {
							n.set ("color", color);
						} else if (e != null) {
							e.set ("color", color);
						} else stderr.printf ("COLOR: uhm no node?\n");
					}
				}
			}
		}
	}

	public static bool import_string (Graph gr, string contents) {
		string row = "";
		string[] foo = contents.split ("\n");
		foreach (var line in foo) {
			if (line.has_suffix ("\\")) {
				row += line [0:-2] + "\n";
				continue;
			}
			import_line (gr, row + line);
			row = "";
		}
	}

	public static bool import (Graph gr, string file) {
		var fd = FileStream.open (file, "r");
		if (fd == null) {
			stderr.printf ("Cannot open: '%s'\n", file);
			return false;
		}
		string row = "";
		while (!fd.eof ()) {
			string line = fd.read_line ();
			if (line == null)
				break;
			if (line.has_suffix ("\\")) {
				row += line [0:-2] + "\n";
				continue;
			} else row += line;
			import_line (gr, row);
			row = "";
		}
		fd = null;
		return true;
	}

	public static bool export (Graph gr, string file) {
		var fd = FileStream.open (file, "w");
		if (fd == null) {
			stderr.printf ("Cannot open: '%s'\n", file);
			return false;
		}
		fd.printf ("digraph code {\n");
		foreach (weak Node node in gr.nodes) {
			string label = node.get ("label").replace ("\n", "\\l");
			string body = node.get ("body").replace ("\n", "\\l");
			fd.printf ("\t\"%s\" [label=\"%s\", shape=\"box\" pos=\"%f,%f\" ];\n",
				label, body, node.x, node.y);
		}
		foreach (weak Edge edge in gr.edges) {
			string color = edge.get ("color");
			fd.printf ("\t\"%s\" -> \"%s\" [color=\"%s\"];\n",
				edge.orig.get ("label"), edge.dest.get ("label"), color);
		}
		fd.printf ("}\n");
		fd = null;
		return true;
	}
}

/*
void main() {
	Graph g = new Graph ();
	//XDot.import (g, "file.xdot");
	XDot.export (g, "out.xdot");
}
*/
