EXT_AR=a
EXT_SO=so
LIBFILE=lib${LIBNAME}.${EXT_AR}

# TODO: Use parvala when possible
GTKON_CFILES=$(subst .gtkon,.c,$(GTKONFILES))
GTKON_OFILES=$(subst .gtkon,.o,$(GTKONFILES))
VALA_CFILES=$(subst .vala,.c,$(VALAFILES))
VALA_OFILES=$(subst .vala,.o,$(VALAFILES))
CFILES=${GTKON_CFILES} ${VALA_CFILES}
VALAFLAGS= --vapidir=../include --Xcc=-I../include 
VALAFLAGS+=$(addprefix --pkg ,$(PACKAGES))
VALALIBFLAGS=--library ${LIBNAME} --vapi=../include/${LIBNAME}.vapi -H ../include/${LIBNAME}.h
OFILES=$(subst .c,.o,$(CFILES))
CFLAGS+=-g -O0

all: lib

lib: ${LIBFILE}

${LIBFILE}: ${OFILES}
	rm -f ${LIBFILE}
	ar -q ${LIBFILE} ${OFILES}

${OFILES}: ${GTKON_CFILES} ${VALA_CFILES}
	${CC} ${CFLAGS} -c -I../include `pkg-config --cflags gtk+-2.0 r_core` ${CFILES}

${VALA_CFILES}: ${VALAFILES}
	valac -C ${VALALIBFLAGS} ${VALAFLAGS} ${VALAFILES}
	@rm -f ${VALA_OFILES}

${GTKON_CFILES}: ${GTKONFILES}
	gtkamlc -C ${VALALIBFLAGS} ${VALAFLAGS} ${GTKONFILES}
	@rm -f ${GTKON_OFILES}

clean:
	rm -f *.c *.${EXT_AR} *.o

.PHONY: main lib clean
