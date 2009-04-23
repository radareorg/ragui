#include ../../config.mk

SOURCES=default_lgrava.vala edge.vala graph.vala lgrava.vala \
	node.vala renderer.vala widget.vala shape.vala
VALAFLAGS=--pkg gtk+-2.0 --pkg cairo -g

grava: $(SOURCES:.vala=.o)
	#[ "${HAVE_VALAC}" = 1 ] && valac -c -g --save-temps *.vala --pkg gtk+-2.0 --pkg cairo -o grava
	# only for releases (not development)
	${CC} -I../include `pkg-config gtk+-2.0 cairo --cflags --libs` cmain.c $(SOURCES:.vala=.o) -o grava

%.o:%.vala
	valac -H ../include/gravawidget.h --library grava --save-temps $(VALAFLAGS) -c $(SOURCES)

c:
	valac --save-temps *.c --pkg gtk+-2.0 --pkg cairo -o grava

novala:
	${CC} `pkg-config gtk+-2.0 cairo --cflags --libs` -I../include -c *.c
	-rm -f cmain.o

clean:
	-mv cmain.c ___
	-rm *.c *.h *.o grava
	-mv ___ cmain.c
