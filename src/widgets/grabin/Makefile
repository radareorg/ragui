VALAFLAGS=--pkg gtk+-2.0 --pkg r_core --vapidir=../include --Xcc=-I../include

all: main

lib:
	valac -C --library grabin --vapi=../include/grabin.vapi -H ../include/grabin.h ${VALAFLAGS} grabin.vala
	gtkamlc -C --library grabinsections --vapi=../include/grabinsections.vapi -H ../include/grabinsections.h --pkg grabin ${VALAFLAGS} grabinsections.gtkon
	gtkamlc -C --library grabinsymbols --vapi=../include/grabinsymbols.vapi -H ../include/grabinsymbols.h --pkg grabin ${VALAFLAGS} grabinsymbols.gtkon
	gtkamlc -C --library grabinimports --vapi=../include/grabinimports.vapi -H ../include/grabinimports.h --pkg grabin ${VALAFLAGS} grabinimports.gtkon
	gtkamlc -C --library grabinstrings --vapi=../include/grabinstrings.vapi -H ../include/grabinstrings.h --pkg grabin ${VALAFLAGS} grabinstrings.gtkon
	gtkamlc -C --library grabinrelocs --vapi=../include/grabinrelocs.vapi -H ../include/grabinrelocs.h --pkg grabin ${VALAFLAGS} grabinrelocs.gtkon
	gtkamlc -C --library grabinfat --vapi=../include/grabinfat.vapi -H ../include/grabinfat.h --pkg grabin ${VALAFLAGS} grabinfat.gtkon
	gtkamlc -C --library grabinall --vapi=../include/grabinall.vapi -H ../include/grabinall.h \
		--pkg grabin --pkg grabinsections --pkg grabinsymbols --pkg grabinimports --pkg grabinstrings --pkg grabinrelocs --pkg grabinfat ${VALAFLAGS} grabinall.gtkon

main: lib
	valac -C --pkg gtk+-2.0 --pkg grabinall ${VALAFLAGS} grabintest.vala
	gcc -I../include `pkg-config --cflags --libs gtk+-2.0 r_core` grabin.c grabinsections.c grabinsymbols.c grabinimports.c grabinstrings.c grabinrelocs.c grabinfat.c grabinall.c grabintest.c -o grabintest

clean:
	rm -f *.c grabintest


.PHONY: main lib
