public struct Radare.CanvasApi.Vector {
	public double x;
	public double y;

	public Vector (double x, double y) {
		this.x = x;
		this.y = y;
	}

	public Vector add (Vector v) {
		this.x += v.x;
		this.y += v.y;
		return this;
	}

	public Vector sub (Vector v) {
		this.x -= v.x;
		this.y -= v.y;
		return this;
	}

	public Vector mul (Vector v) {
		this.x *= v.x;
		this.y *= v.y;
		return this;
	}

	public Vector div (Vector v) {
		this.x /= v.x;
		this.y /= v.y;
		return this;
	}
}
