/*
 *  Grava - General purpose graphing library for Vala
 *  Copyright (C) 2007-2010  pancake <youterm.com>
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

using GLib;
using Cairo;

public class Grava.Graph {
	public Layout layout;
	public SList<Node> selhist;
	public List<Node> nodes;
	public SList<Edge> edges;
	public HashTable<string,string> data;
	public static unowned Node selected = null;
	public double zoom  = 1;
	public double panx  = 0;
	public double pany  = 0;
	public double angle = 0;
	public bool inverse = false;

	public Graph () {
		//layout = new DefaultLayout ();
		layout = new TreeLayout ();
		init ();
	}

	public Graph.with_layout (Layout layout) {
		init ();
		this.layout = layout;
	}

	public void do_zoom(double z) {
		zoom += z;
		if (z>0) {
			panx += panx*z;
			pany += pany*z;
		} else {
			panx += panx*z;
			pany += pany*z;
		}
	}

	public Node? get_node(string key, string val) {
		foreach (unowned Node node in nodes) {
			if (node.get (key) == val)
				return node;
		}
		return null;
	}

	public void undo_select() {
		uint length = selhist.length ();
		selected = selhist.nth_data (length-1);
		selhist.remove (selected);
	}

	/* TODO: Add boolean argument to reset layout too */
	public void init () {
		layout.reset();
		data = new HashTable<string, string> (str_hash, str_equal);
		nodes = new List<Node> ();
		edges = new SList<Edge> ();
		selhist = new SList<Node> ();
	}

	public new void set(string key, string val) {
		data.insert (key, val);
	}

	public new string get(string key) {
		return data.lookup (key);
	}

	public void select_next() {
/*
		foreach(unowned Node node in nodes) {
			if (Graph.selected == null) {
				selected = node;
				Graph.selected = node;
				selhist.append(selected);
				break;
			}
			if (selected == node) {
				Graph.selected = node;
				selected = null;
			}
		}
*/
		foreach (unowned Node node in nodes) {
			Graph.selected = selected = node;
			break;
		}
	}

	public void select_true() {
		if (selected == null)
			return;

		foreach (Edge edge in edges) {
			if (selected == edge.orig) {
				if (edge.get("color") == "green") {
					selected = edge.dest;
					selhist.append(selected);
					break;
				}
			}
		}
	}

	public void select_false() {
		if (selected == null)
			return;
		foreach (Edge edge in edges) {
			if (selected == edge.orig) {
				if (edge.get ("color") == "red") {
					selected = edge.dest;
					selhist.append (selected);
					break;
				}
			}
		}
	}

	public static bool is_selected(Node n) {
		return n == selected;
	}

	public void update() {
		layout.run (this);
	}

	public void center () {
		double x = 0;
		double y = -10;
		this.zoom = 1;
/*
		foreach (unowned Node node in nodes) {
			if (y==0 || node.y<y) {
				x = node.x-(node.w/2);
				y = node.y;
			}
			Graph.selected = selected = node;
			break;
		}
*/
		this.panx = x;
		this.pany = y;
	}

	// esteve modificat perque insereixi a la llista ordenat per baseaddr.
	// volia fer servir node.sort, pero no m'ha sortit...
	public void add_node(Node n) {
		int count;
		Node p;
		bool ins;
		uint len = nodes.length ();

		layout.set_graph (this);
		n.fit();
		
		ins = false;
		for (count=0; count<len; count++) {
			p = nodes.nth_data (count);
			//stdout.printf ("adding node base at %x , this is %x\n", p.baseaddr, n.baseaddr );

			if (p.baseaddr>=n.baseaddr) {
				ins = true;
				nodes.insert (n, count);
				break;
			}
		}

		if (ins == false)
			nodes.append (n);
	}

	public void add_edge(Edge e) {
		edges.append (e);
	}

	public SList<Node> unlinked_nodes() {
		SList<Node> ret = new SList<Node> ();
		foreach (unowned Node node in nodes) {
			bool found = false;
			foreach (unowned Edge edge in edges ) {
				if (node == edge.orig || node == edge.dest) {
					found = true;
					break;
				}
			}
			if (!found)
				ret.append (node);
		}
		return ret;
	}

	public SList<Node> outer_nodes (Node n) {
		SList<Node> ret = new SList<Node> ();
		foreach(unowned Edge edge in edges) {
			if (edge.visible && (edge.orig == n))
				ret.append (edge.dest);
		}
		return ret;
	}

	public SList<Node> inner_nodes (Node n) {
		SList<Node> ret = new SList<Node> ();
		foreach (unowned Edge edge in edges) {
			if (edge.visible && (edge.dest == n))
				ret.append (edge.orig);
		}
		return ret;
	}

	public unowned Node? click (double x, double y) {
		double z = zoom;
		// XXX ULTRA INEFFICIENT
		var sedon = nodes.copy ();
		sedon.reverse ();
		foreach (unowned Node node in sedon) {
			if ((x >= (node.x*z)) && (x <= (node.x*z+node.w*z))
			&&  (y >= (node.y*z)) && (y <= (node.y*z+node.h*z)))
				return node;
		}
		return null;
	}

	public bool overlaps(Node n) {
		foreach (unowned Node node in nodes) {
			if (node != n && node.overlaps (n))
				return true;
		}
		return false;
	}

	/* TODO: this should be renderer independent, not cairo-specific */
	public void draw(Context ctx) {
		if (ctx == null)
			return;
		if (inverse) ctx.set_source_rgba (0,0,0,1);
		else ctx.set_source_rgba (1, 1, 1, 1);
		ctx.translate (panx, pany);
		ctx.scale (zoom, zoom);
		//ctx.translate( panx*zoom, pany*zoom);
		ctx.rotate (angle);
	
		/* blank screen */
		ctx.paint ();

		/* draw bg picture
		ctx.save();
		ctx.set_source_surface(s, panx, pany);
		ctx.paint();
		ctx.restore ();
		*/
		foreach (unowned Edge edge in edges)
			if (edge.visible)
				Renderer.draw_edge (ctx, edge);
		foreach (unowned Node node in nodes)
			if (node.visible)
				Renderer.draw_node (ctx, node);
	}

	public void add(Node n) {
		nodes.append (n);
	}

	public void link(Node n, Node n2) {	
		edges.append (new Edge (n, n2));
	}
}
