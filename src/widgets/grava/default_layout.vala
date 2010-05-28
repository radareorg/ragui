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

using GLib;

public class Grava.DefaultLayout : Grava.Layout {
	public double y_offset = 100;
	public double x_offset = 50;
	private unowned Graph graph;
	public HashTable<string,Node> data;

	construct {
		data = new HashTable<string, Node>.full (
			str_hash, str_equal, g_free, Object.unref);
	}

	public new void reset() {
		print ("RESETING LAYOUT\n");
		foreach (unowned Node node in graph.nodes) {
			print ("RESETING LAYOUT+++++\n");
			setxy (node);
		}
	}

	public void reset_real() {
		foreach (unowned Node node in graph.nodes) {
			graph.nodes.remove (node);
		}
	}

	private void treenodes(Node n) {
		int ox = 0;
		SList<Node> nodes = graph.outer_nodes (n);
		foreach (unowned Node node in nodes) {
			node.y = n.y+n.h+y_offset;
			node.x += n.w+ ox;
			ox += 50;
			treenodes (node);
		}
	}

	public void setxy(Node n) {
		Node m = data.lookup (n.get ("offset"));
		if (m == null) {
			Node no = new Node ();
			no.set ("offset", n.get ("offset"));
			no.x = n.x;
			no.y = n.y;
			no.w = n.w;
			no.h = n.h;
			data.insert (n.get ("offset"), no);
		} else {
			m.x = n.x;
			m.y = n.y;
			m.w = n.w;
			m.h = n.h;
		}
	}

	public bool getxy(ref Node n) {
		Node m = data.lookup (n.get ("offset"));
		if (m != null) {
			n.x = m.x;
			n.y = m.y;
			n.w = m.w;
			n.h = m.h;
stdout.printf("TAKEND FOR %s\n", n.get("offset"));
			return true;
		}
stdout.printf("NOT TAKEND FOR %s\n", n.get("offset"));
		
		return false;
	}

	public void walkChild(Node? node, int level) {
		if (level<1 || node == null)
			return;
		foreach(unowned Edge edge in graph.edges) {
			if (edge.orig == node) {
				edge.dest.y = edge.orig.y + edge.orig.h + y_offset;
				walkChild(edge.dest, --level);
			}
		}
	}

	public unowned Node? get_parent(Node node) {
		foreach(unowned Edge edge in graph.edges) {
			if (edge.dest == node)
				return edge.orig;
		}
		return null;
	}

	public override void set_graph(Graph graph) {
		this.graph = graph;
	}

	public override void run(Graph graph) {
		this.graph = graph; // XXX
		double last_y;
		//SList<Node> paint_nodes;
		//int i, inorig, indst ,k;
		//Node n,p, destn;
		//Edge e;

		// reset all node positions

		last_y = 50;

/*
		// Tots vertical, un sota l'altr ordenats per base addr
		foreach(unowned Node node in graph.nodes) {
			if (!node.visible) continue;
			// reset node positions
			node.x = 50;
			node.fit();
			node.y = last_y ;
			last_y = node.y + node.h + 50 ;
			//stdout.printf(" at %f %s %x\n", node.y, node.get ("label" ) , node.baseaddr );
		}
		
		// Per cada node. Segueixo la condiciÃ³ certa, tots els nodes que estiguin
		// entre el node que estic mirant i el de la condicio certa els desplaÃ§o a la dreta.
		// Tambe  apropo  el node desti a l'origen.
		//
		// Entre el node que miro i el desti vol dir que la x sigui la mateixa.
		//
		for( i = 0 ; i < graph.nodes.length() ; i ++ ) {
			n = graph.nodes.nth_data ( i );
			//if (getxy(ref n))
			//	continue;
			string s = n.get("offset");
			if (s != null) {
				Node m = data.lookup(s);
				if (m != null) {
					n.x = m.x;
					n.y = m.y;
					n.w = m.w;
					n.h = m.h;
					stdout.printf("FUCKA! %f %f\n", n.x, n.y);
					continue;
				}
			}
			stdout.printf("---- not ounfd !\n");

			/// busco l'edge verd d'aquest node
			///
			found = false;
			destn = null;
			foreach(unowned Edge edge in graph.edges) {
				if (edge.orig == n && edge.jmpcnd == true) {
					if(d)stdout.printf ( "0x%x ----> 0x%x\n",edge.orig.baseaddr ,edge.dest.baseaddr );
					destn = edge.dest;
					found = true;
					break;
				}
			}

			/// n es el node origen.
			/// destn es el node desti
			///
			last_y = n.y + n.h + 10 ;

			// Si la base del node origen es < que le desti .
			// sempre anem avall.
			//
			if ( (found == true ) && ( n.baseaddr < destn.baseaddr ) ) {
				/// Busco el node mes ample.
				///
				double maxw = 0;
				for( k = (i+1) ;  k < graph.nodes.length() ; k ++ ) {
					p = graph.nodes.nth_data ( k );
					if ( (p.x == n.x) && ( p.w > maxw ) )
						maxw = p.w;
				}
				/// DesplaÃ§o
				///
				for( k = (i+1) ;  k < graph.nodes.length() ; k ++ ) {
					p = graph.nodes.nth_data ( k );
					
					if(d)stdout.printf ( "Displacing 0x%x\n", p.baseaddr );
				
					// El node estava entre el node origen i el desti
					if ( p.x == n.x )
						p.x += ( maxw + 10 );
				
					/// Es ja el node desti.
					if ( p == destn ) {
						if(d)stdout.printf ( "AT 0x%x\n", p.baseaddr );
						destn.x = n.x; 
						destn.y = n.y + n.h + 50;
						break;
					}
				}
			}
			setxy(n);
		}

		return;
*/

		walkChild (graph.selected, 5);
		//walkChild(graph.selected); //
		foreach (unowned Node node in graph.nodes) {
			walkChild (node, 5);
		}

		foreach (unowned Node node in graph.nodes) {
			if (!node.visible) continue;

			unowned Node parent = get_parent (node);
			if (parent != null)
				node.x = parent.x;
		}

		SList<Node> nodz;
		foreach (unowned Node n in graph.nodes) {
			double totalx = 0;
			nodz = new SList<Node> ();
			nodz.append (n);
			foreach (unowned Node n2 in graph.nodes) {
				if (n != n2 && n.overlaps (n2)) {
					totalx += n2.w+x_offset;
					n.x += n.w + n2.w + x_offset;
					nodz.append (n2);
				}
			}
			totalx /= 2;
			foreach (unowned Node n2 in nodz) {
				if (n != n2 && n.overlaps (n2)) {
					totalx += n2.w;
					n.x -= totalx;
				}
			}
			nodz = null;
		}

		foreach (unowned Node node in graph.nodes) {
			if (!node.visible)
				continue;
			if (graph.overlaps(node))
				node.x += node.w;
		}
		foreach (unowned Node node in graph.nodes) {
			if (!node.visible)
				continue;
			foreach (unowned Edge edge in graph.edges) {
				if (edge.orig==node && edge.dest.y<node.y)
					node.y = edge.dest.y-(node.h-y_offset)*3;
			}
		}
		/**
		 * primer incremento les x mentres vaig guardant el totalx
		 * guardo en una llista enlla,cada tots els nodos q he mogut
		 * els recorro again i els delpla,co a lesqerra lo que toquin
		 */
	}
}

