public struct Radare.CanvasApi.Color {
	public double r;
	public double g;
	public double b;
	public double a;

	public Color (double r, double g, double b, double a = 1) {
		this.r = r;
		this.g = g;
		this.b = b;
		this.a = a;
	}

	public Color.from_int (int r, int g, int b, int a = 255) {
		this.r = (r%255)/255;
		this.g = (g%255)/255;
		this.b = (b%255)/255;
		this.a = (a%255)/255;
	}
}
