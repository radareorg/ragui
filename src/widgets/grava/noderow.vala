using Grava;

public class Grava.NodeRow {
	public List<Grava.Node> nodes;
	public NodeRow () {
		nodes = new List<Grava.Node>();
	}
	public void append(Grava.Node node) {
		foreach (var n in nodes) {
			if (n == node)
				return;
		}
		nodes.append (node);
	}
	public int length() {
		return (int) nodes.length ();
	}
}
