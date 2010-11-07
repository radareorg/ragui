VALAFLAGS=--pkg gtk+-2.0 --pkg r_core --vapidir=../include --Xcc=-I../include

all:
	valac -C --library grabin --vapi=../include/grabin.vapi -H ../include/grabin.h ${VALAFLAGS} grabin.vala
	gtkamlc -C --save-temps --vapi=../include/grabinsections.vapi -H ../include/grabinsections.h --pkg grabin ${VALAFLAGS} grabinsections.gtkon
	valac -C --pkg grabin --pkg grabinsections ${VALAFLAGS} main.vala
	gcc -I../include `pkg-config --cflags --libs gtk+-2.0 r_core` grabin.c grabinsections.c main.c -o grabinsections
