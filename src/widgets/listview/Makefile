VALAFILES=listview.vala main.vala
CFILES=
VALAFLAGS=--pkg gtk+-2.0 --Xcc=-I../include
OUT_BIN=listview
OUT_HFILE=../include/listview.h
CFLAGS+=-I../include `pkg-config --cflags gtk+-2.0 r_asm r_util`
OFILES=$(subst .vala,.o,${VALAFILES})

.PHONY: main objs lib

main: lib all

objs: ${OFILES}

lib: ../include/listview.h
	valac -C --library listview --vapi=../include/listview.vapi ${VALAFLAGS} ${VALAFILES} -H ../include/listview.h
	${MAKE} objs
	rm -f liblistview.a
	ar -q liblistview.a ${OFILES}

include ../parvala.mk
