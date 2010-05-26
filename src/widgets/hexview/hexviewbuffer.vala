/*
 *  Copyright (C) 2010  pancake <youterm.com>
 */

using GLib;
using Cairo;
using Gtk;
using Gdk;

public class Hexview.Buffer {
	public uint64 start;
	public uint64 end;
	public uint64 size;
	public uint8[] bytes;

	public Buffer () {
		bytes = null;
	}

	public uint8 *get_ptr(int x, int y) {
		if (bytes == null)
			update (x, y);
		if (bytes == null)
			return null;
		uint8 *ptr = (uint8*)bytes;
		return ptr + y*16+x;
	}

	public signal void update(uint64 addr, int sz);
}
