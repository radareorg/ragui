VALAFILES=grasmwidget.vala
CFILES=`ls ../grava/*.c|grep -v main` cmain.c
VALAFLAGS=--pkg gtk+-2.0 --pkg r_asm --pkg r_util --pkg grava --vapidir=../grava --Xcc=-I../include
OUT_BIN=grasm
OUT_HFILE=../include/grasmwidget.h
CFLAGS+=-I../include `pkg-config --cflags gtk+-2.0 r_asm r_util`
OFILES=$(subst .vala,.o,${VALAFILES})

.PHONY: main objs lib

main: lib all

objs: ${OFILES}

lib: $(OUT_HFILE)
	valac --vapi ../include/grasmwidget.vapi --library grasm -Cc --pkg gtk+-2.0 grasmwidget.vala $(VALAFLAGS)
	${MAKE} objs
	rm -f libgrasm.a
	ar -q libgrasm.a ${OFILES}
	#@cp -f .vala-aux/grasmwidget.vapi ../include

include ../parvala.mk
