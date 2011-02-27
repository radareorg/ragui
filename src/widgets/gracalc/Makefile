VALAFLAGS=--pkg gtk+-2.0 --pkg r_core --vapidir=../include --Xcc=-I../include
CFILES=gracalc.c
OFILES=$(subst .c,.o,$(CFILES))

all: main

# TODO: use a single gtkamlc line
lib:
	# generate the gracalcwidget library
	gtkamlc -C --library gracalc --pkg segmentbar --vapi=../include/gracalc.vapi -H ../include/gracalc.h ${PKG} ${VALAFLAGS} gracalc.gtkon
	${CC} ${CFLAGS} -c -I../include `pkg-config --cflags gtk+-2.0 r_core` ${CFILES}
	rm -f libgracalc.a
	ar -q libgracalc.a ${OFILES}

main: lib

clean:
	rm -f *.c *.a *.o

.PHONY: main lib
