all: widget_asm

widget_asm:
	valac --pkg gtk+-2.0 --pkg r_asm --pkg r_util widget_asm.vala
	#valac -C --pkg gtk+-2.0 --pkg libr widget_asm.vala
	#gcc -o widget_asm `pkg-config --libs --cflags gtk+-2.0 libr` widget_asm.c

clean:
	rm -f widget_asm
