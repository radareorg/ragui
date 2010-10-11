VALAFILES=grasmwidget.vala
CFILES=`ls ../grava/*.c|grep -v main` cmain.c
VALAFLAGS=--pkg gtk+-2.0 --pkg r_asm --pkg r_util --pkg grava --vapidir=../grava --Xcc=-I../include
OUT_BIN=grasm
OUT_HFILE=../include/grasmwidget.h

.PHONY: main lib

main: lib all

lib: ${OUT_HFILE}
	@cp -f grasmwidget.vapi ../include

include ../parvala.mk
