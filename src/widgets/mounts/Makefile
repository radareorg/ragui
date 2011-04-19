VALAFLAGS=--pkg gtk+-2.0 --pkg r_core --pkg r_fs --vapidir=../include --Xcc=-I../include --pkg listview
#VALAFLAGS+=--pkg guicore --vapidir=../..
CFILES=mounts.c
OFILES=$(subst .c,.o,$(CFILES))

all: main

# TODO: use a single gtkamlc line
lib:
	# generate the mountswidget library
	gtkamlc -C --library mounts --vapi=../include/mounts.vapi -H ../include/mounts.h ${PKG} ${VALAFLAGS} mounts.gtkon
	${CC} ${CFLAGS} -c -I../include `pkg-config --cflags gtk+-2.0 r_core` ${CFILES}
	rm -f libmounts.a
	ar -q libmounts.a ${OFILES}

main: lib

clean:
	rm -f *.c *.a *.o

.PHONY: main lib
