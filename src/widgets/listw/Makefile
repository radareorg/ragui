VALAFILES=listview.vala main.vala
CFILES=
VALAFLAGS=--pkg gtk+-2.0 --Xcc=-I../include
OUT_BIN=listw
OUT_HFILE=../include/listview.h

.PHONY: main lib

main: lib all

lib: ../include/listview.h
	valac -C --library listview --vapi=../include/listview.vapi ${VALAFLAGS} ${VALAFILES} -H ../include/listview.h
	#cp *.h
	#@cp -f .vala-aux/listview.vapi ../include

include ../parvala.mk
