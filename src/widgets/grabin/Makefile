VALAFLAGS=--pkg gtk+-2.0 --pkg r_core --pkg r_util --vapidir=../include --Xcc=-I../include --pkg segmentbar
PKG=--pkg grabin --pkg grabinsections --pkg grabinsymbols --pkg grabinimports
PKG+=--pkg grabinstrings --pkg grabinrelocs --pkg grabinfat
CFILES=grabin.c grabinsections.c grabinsymbols.c grabinimports.c
CFILES+=grabinstrings.c grabinrelocs.c grabinfat.c grabinall.c 
OFILES=$(subst .c,.o,$(CFILES))

all: main

# TODO: use a single gtkamlc line
lib:
	# generate the grabinwidget library
	valac -C --library grabin --vapi=../include/grabin.vapi -H ../include/grabin.h ${VALAFLAGS} grabin.vala
	gtkamlc -C --library grabinsections --vapi=../include/grabinsections.vapi -H ../include/grabinsections.h --pkg grabin ${VALAFLAGS} grabinsections.gtkon
	gtkamlc -C --library grabinsymbols --vapi=../include/grabinsymbols.vapi -H ../include/grabinsymbols.h --pkg grabin ${VALAFLAGS} grabinsymbols.gtkon
	gtkamlc -C --library grabinimports --vapi=../include/grabinimports.vapi -H ../include/grabinimports.h --pkg grabin ${VALAFLAGS} grabinimports.gtkon
	gtkamlc -C --library grabinstrings --vapi=../include/grabinstrings.vapi -H ../include/grabinstrings.h --pkg grabin ${VALAFLAGS} grabinstrings.gtkon
	gtkamlc -C --library grabinrelocs --vapi=../include/grabinrelocs.vapi -H ../include/grabinrelocs.h --pkg grabin ${VALAFLAGS} grabinrelocs.gtkon
	gtkamlc -C --library grabinfat --vapi=../include/grabinfat.vapi -H ../include/grabinfat.h --pkg grabin ${VALAFLAGS} grabinfat.gtkon
	gtkamlc -C --library grabinall --pkg segmentbar --vapi=../include/grabinall.vapi -H ../include/grabinall.h ${PKG} ${VALAFLAGS} grabinall.gtkon
	${CC} ${CFLAGS} -c -I../include `pkg-config --cflags gtk+-2.0 r_core` ${CFILES}
	rm -f libgrabin.a
	ar -q libgrabin.a ${OFILES}

main: lib
	valac -C --pkg gtk+-2.0 ${PKG} --pkg segmentbar --pkg grabinall ${VALAFLAGS} grabintest.vala 
	${CC} ${CFLAGS} ${LDFLAGS} -I../include `pkg-config --cflags --libs gtk+-2.0 r_core` ${CFILES} ../segmentbar/segmentedbar.c grabintest.c -o grabintest

clean:
	rm -f *.c grabintest

.PHONY: main lib
