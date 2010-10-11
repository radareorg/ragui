public class Radare.CanvasApi.Palette {
	private Color[] colors = new Color[16];

	public Color get(int idx) {
		if (idx<0 || idx>colors.length)
			idx = 0;
		return colors[idx];
	}

	public bool set(int idx, Color color) {
		bool ret = true;
		if (idx<0 || idx>colors.length)
			ret = false;
		else colors[idx] = color;
		return ret;
	}
}
