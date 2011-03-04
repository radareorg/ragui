VALAFLAGS=--pkg gtk+-2.0 --pkg r_core --vapidir=../include --Xcc=-I../include --pkg grava
CFILES=gradiff.c
OFILES=$(subst .c,.o,$(CFILES))

all: main

# TODO: use a single gtkamlc line
lib:
	# generate the gradiffwidget library
	gtkamlc -C --library gradiff --vapi=../include/gradiff.vapi -H ../include/gradiff.h ${PKG} ${VALAFLAGS} gradiff.gtkon
	${CC} ${CFLAGS} -c -I../include `pkg-config --cflags gtk+-2.0 r_core` ${CFILES}
	rm -f libgradiff.a
	ar -q libgradiff.a ${OFILES}

main: lib

clean:
	rm -f *.c *.a *.o

.PHONY: main lib
