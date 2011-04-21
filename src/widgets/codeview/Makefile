VALAFILES=codecontext.vala codejump.vala codeline.vala codeview.vala
CFILES=cmain.c
VALAFLAGS=--pkg gtk+-2.0 --Xcc=-I../include
OUT_BIN=codeview
OUT_HFILE=../include/codeview.h
OFILES=$(subst .vala,.o,$(VALAFILES))
CFLAGS+=-I../include `pkg-config --cflags gtk+-2.0`

.PHONY: main lib

main: lib all

objs: ${OFILES}

lib: ../include/codeview.h
	valac -C --library codeview --vapi=../include/codeview.vapi ${VALAFLAGS} ${VALAFILES} -H ../include/codeview.h
	${MAKE} objs
	rm -f libcodeview.a
	ar -q libcodeview.a ${OFILES}

include ../parvala.mk
