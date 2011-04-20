CFILES=$(subst .gtkon,.c,$(GTKONFILES))
VALAFLAGS= --vapidir=../include --Xcc=-I../include 
VALAFLAGS+=$(addprefix --pkg ,$(PACKAGES))
OFILES=$(subst .c,.o,$(CFILES))
CFLAGS+=-g -O0

all: main

# TODO: use a single gtkamlc line
lib:
	# generate the mountswidget library
	gtkamlc -C --library ${LIBNAME} --vapi=../include/${LIBNAME}.vapi -H ../include/${LIBNAME}.h ${PKG} ${VALAFLAGS} ${GTKONFILES}
	${CC} ${CFLAGS} -c -I../include `pkg-config --cflags gtk+-2.0 r_core` ${CFILES}
	rm -f lib${LIBNAME}.a
	ar -q lib${LIBNAME}.a ${OFILES}

main: lib

clean:
	rm -f *.c *.a *.o

.PHONY: main lib clean
