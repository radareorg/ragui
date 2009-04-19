VALAFLAGS=--pkg gtk+-2.0 --pkg cairo --pkg libr --pkg grava --vapidir=../grava

SOURCES=grasmwidget.vala

all:
	-valac -g -H grasmwidget.h -Cc ${VALAFLAGS} *.vala
	${CC} -c -g `pkg-config gtk+-2.0 libr cairo --cflags` -I/usr/include/libr -I../grava $(SOURCES:.vala=.c)
	${CC} -g `pkg-config gtk+-2.0 cairo libr --cflags --libs` cmain.c $(SOURCES:.vala=.o) -o a.out ../grava/*.o

clean:
	mv cmain.c __
	rm -f *.c *.h *.o a.out
	mv __ cmain.c
