/*
 *  Grava - General purpose graphing library for Vala
 *  Copyright (C) 2007-2010   pancake <youterm.com>
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

using Grava;

public class Grava.TreeLayout : Grava.Layout {
	const int CENTER_HACK = 200;
	const int HEIGHT_HACK = 200;

	private unowned Graph graph;

	public TreeLayout() {
	}

	public override void set_graph(Graph graph) {
		this.graph = graph; // uh?
	}

	List<Grava.Node> sources;
	private int count_source(Grava.Node node) {
		int count = 0;
		sources = new List<Grava.Node>();
		foreach (var edge in graph.edges) {
			if (edge.orig == node) {
				count++;
				sources.append (edge.dest);
			}
		}
		return count;
	}

	List<Grava.Node> targets;
	private int count_target(Grava.Node node) {
		int count = 0;
		targets = new List<Grava.Node>();
		foreach (var edge in graph.edges) {
			if (edge.dest  == node) {
				count++;
				targets.append (edge.orig);
			}
		}
		return count;
	}

	public override void run(Graph graph) {
		List<NodeRow> rows = new List<NodeRow>();
		/* do it here */
		var nodes = new List<Grava.Node>();
		print ("Running tree layout\n");
		var row = new NodeRow ();
		var nextrow = new NodeRow ();

		foreach (var node in graph.nodes)
			node.layer = -1;

		foreach (var node in graph.nodes) {
			int source = count_source (node);
			int target = count_target (node);
			print ("node: %s (%d %d)\n", node.get ("label"), source, target);
			if (target == 0) {
				row.append (node);
				foreach (var n in sources) {
					print ("CHILD %s\n", n.get ("label"));
					n.layer = 0;
					nextrow.append (n);
				}
			} else nodes.append (node);
		}
		rows.append (row);

		if (nextrow.length () == 0) {
			var node = graph.nodes.nth_data (0);
			if (node != null) {
				nextrow.append (node);
				count_target (node);
				foreach (var n in sources)
					nextrow.append (n);
			} else {
				print ("EPIC GRAPH FAIL!\n");
				return;
			}
		}
		rows.append (nextrow);

		for (int layer = 1; ; layer ++) {
			row = new NodeRow ();
			print ("LAYER == %d\n", layer);
			foreach (var node in nextrow.nodes) {
				count_source (node);
				print ("  NODE: (%s)\n", node.get("label"));
				foreach (var n in sources) {
					if (n.layer == -1) {
						print ("    CHILD %s\n", n.get ("label"));
						row.append (n);
						n.layer = layer;
					} else print ("    CHILD (DUPPED) (%s)\n", n.get ("label"));
				}
			}
			if (row.length () == 0) {
				print ("BREAK (no more layers found)\n");
				break;
			}
			rows.append (row);
			nextrow = row;
		}

		double rowwidth;
		double y = 0;
		int nrow = 0;
		int count = 0;
		double rowheight, lastwidth;
		foreach (var nr in rows) {
			count = 0;
			print ("### ROW %d\n", (int)y);
			rowheight = 0;
			lastwidth = 0;
			rowwidth = 0;
			foreach (var n in nr.nodes)
				rowwidth += n.w;
			rowwidth += (nr.length ()*20);
			lastwidth = 0-(rowwidth/2);
			foreach (var n in nr.nodes) {
				n.layer = nrow;
				n.y = y;
				n.x = lastwidth + CENTER_HACK;
				print ("  + NODE (%s) (%f,%f)\n", n.get ("label"), n.w, n.h);
				lastwidth += n.w + 20;
				count++;
				if (n.h > rowheight)
					rowheight = n.h;
			}
			y += (rowheight+HEIGHT_HACK);
			nrow++;
		}
	}
}
