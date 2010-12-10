VALAFLAGS=--pkg gtk+-2.0 --pkg r_core --vapidir=../include --Xcc=-I../include
CFILES=gcode.c

all: main

lib:
	gtkamlc -C --library gcode --vapi=../include/gcode.vapi -H ../include/gcode.h ${VALAFLAGS} gcode.gtkon

main: lib
	valac -C ${VALAFLAGS} --pkg gcode gcodetest.vala
	gcc -I../include `pkg-config --cflags --libs gtk+-2.0 r_core` ${CFILES}  gcodetest.c -o gcodetest

clean:
	rm -f *.c gcodetest


.PHONY: all lib main clean
