#include ../../config.mk
CC?=gcc

VALAFLAGS=--pkg gtk+-2.0 --pkg cairo --pkg posix -g
VALAFLAGS+=-D USE_VALA14

SOURCES=default_layout.vala edge.vala graph.vala layout.vala \
	node.vala renderer.vala widget.vala shape.vala dot.vala \
	tree_layout.vala noderow.vala

grava: $(SOURCES:.vala=.o) cmain.o
	#[ "${HAVE_VALAC}" = 1 ] && valac -c -g --save-temps *.vala --pkg gtk+-2.0 --pkg cairo -o grava
	# only for releases (not development)
	${CC} ${CFLAGS} ${LDFLAGS} -I../include `pkg-config gtk+-2.0 cairo --cflags --libs` cmain.o $(SOURCES:.vala=.o) -o grava

cmain.o: cmain.c ../include/grava.h
	${CC} ${CFLAGS} -I../include -o cmain.o -c `pkg-config --cflags gtk+-2.0 cairo` cmain.c


valadot:
	@echo TODO: dunno how to build this stuff

lib:
	-valac -H ../include/grava.h --library grava -Cc ${VALAFLAGS} ${SOURCES}
	cp grava.vapi ../include
	${CC} ${CFLAGS} -c `pkg-config gtk+-2.0 cairo --cflags` $(SOURCES:.vala=.c)
	rm -f libgrava.a
	ar -q libgrava.a $(SOURCES:.vala=.o)

%.o:%.vala
	valac -H ../include/grava.h --library grava --save-temps $(VALAFLAGS) -c $(SOURCES)

c:
	valac --save-temps *.c --pkg gtk+-2.0 --pkg cairo -o grava

novala:
	${CC} ${CFLAGS} `pkg-config gtk+-2.0 cairo --cflags --libs` -I../include -c *.c
	-rm -f cmain.o

gdot:
	valac ${VALAFLAGS} *.vala -o gdot

clean:
	-mv cmain.c ___
	-rm *.c *.h *.o grava
	-mv ___ cmain.c
