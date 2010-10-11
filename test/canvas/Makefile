PKG=--pkg gtk+-2.0

all:
	valac -C -o bin ${PKG} *.vala
	gcc -g `pkg-config --libs --cflags gtk+-2.0` *.c -o bin
