VALAFLAGS=--pkg gtk+-2.0 --pkg r_core --vapidir=../include --Xcc=-I../include
CFILES=texttagview.c

all: main

lib:
	gtkamlc -C --library texttagview --vapi=../include/texttagview.vapi -H ../include/texttagview.h ${VALAFLAGS} texttagview.gtkon

main: lib
	valac -C ${VALAFLAGS} --pkg texttagview gcodetest.vala
	gcc -I../include `pkg-config --cflags --libs gtk+-2.0 r_core` ${CFILES}  gcodetest.c -o gcodetest

clean:
	rm -f *.c gcodetest


.PHONY: all lib main clean
