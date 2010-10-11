public struct Radare.CanvasApi.Animation {
	public const int STEP_TIME = 10;
	public Vector accel;
	public Vector speed;
	public Vector vector;
	public int stepi;
	public int msecs;

	public Animation.empty () {
		msecs = 0;
		vector = Vector (0, 0);
	}

	public Animation (Vector accel, Vector speed, int msecs) {
		this.accel = accel;
		this.speed = speed;
		this.msecs = msecs;
		this.stepi = 0;
		vector = Vector (0, 0);
	}

	public bool step () {
		if (msecs <= 0)
			return false;
		msecs -= STEP_TIME;
		this.stepi++;

		double t = (stepi * STEP_TIME);
/*
		vector = Vector (
			( (t * speed.x) + (t * accel.x * accel.x)),
			( (t * -speed.y) + (t * -(accel.y * accel.y)))).div (Vector (1000, 1000)
		);
// exponential acceleration
		vector = Vector (
			(t/1000) * (speed.x + (accel.x * (t/1000))),
			(t/1000) * (speed.y + (accel.y * (t/1000)))
		);
// logaritmic acceleration
		vector = Vector (
			(t * (speed.x + (accel.x)),
			(t * (speed.y + (accel.y))
		);
*/
		// exponential
		vector = Vector (speed.x, speed.y);
		vector.add (Vector (accel.x*(t/1000), (accel.y*(t/1000)) ));
		vector.mul (Vector (t/1000, t/1000));

//print (@"t:$(t) stepi: $(stepi) msecs:$(msecs) = vx:$(vector.x) vy:$(vector.y)\n");
		return (msecs>0);
	}
}
