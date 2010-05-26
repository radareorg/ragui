all:
	valac --Xcc=-O3 --pkg gtk+-2.0 hexview.vala main.vala hexviewbuffer.vala

lib:
	valac -H ../include/hexview.h --library hexview -Cc --pkg gtk+-2.0 hexview.vala hexviewbuffer.vala
	#${CC} -c `pkg-config gtk+-2.0 cairo --cflags` hexview.c
	cp hexview.vapi ../include
#	valac --save-temps --pkg gtk+-2.0 HexView.vala
