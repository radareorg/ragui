VALAFLAGS=--pkg gtk+-2.0 --pkg r_core --vapidir=../include --Xcc=-I../include

all:
	valac -C --library grabin --vapi=../include/grabin.vapi -H ../include/grabin.h ${VALAFLAGS} grabin.vala
	gtkamlc -C --library grabinsections --vapi=../include/grabinsections.vapi -H ../include/grabinsections.h --pkg grabin ${VALAFLAGS} grabinsections.gtkon
	gtkamlc -C --library grabinsymbols --vapi=../include/grabinsymbols.vapi -H ../include/grabinsymbols.h --pkg grabin ${VALAFLAGS} grabinsymbols.gtkon
	gtkamlc -C --pkg grabin --pkg grabinsections --pkg grabinsymbols ${VALAFLAGS} grabintest.gtkon
	gcc -I../include `pkg-config --cflags --libs gtk+-2.0 r_core` grabin.c grabinsections.c grabinsymbols.c grabintest.c -o grabintest
