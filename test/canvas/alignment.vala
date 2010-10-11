namespace Radare.CanvasApi {

public enum Margin {
	LEFT,
	RIGHT,
	TOP,
	BOTTOM,
}

[Flags]
public enum Align {
	LEFT = 1,
	RIGHT = 2,
	TOP = 4,
	BOTTOM = 8,
	NONE = 0
}

public struct Alignment {
	public bool enabled;
	public Align type;
	public double margin[4];
	public Element? reference; // beware.. we can cause disasters

	public Alignment () {
		/* alignment */
		this.enabled = false;
		this.type = Align.NONE;
		for (int i = 0; i < 4; i++) {
			this.margin[i] = 0.0;
		}
		this.reference = null;
	}
}

}
