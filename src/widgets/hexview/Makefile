VALAFILES=hexview.vala main.vala hexviewbuffer.vala
VALAFLAGS=--pkg gtk+-2.0
OUT_BIN=hexview
OUT_HFILE=../include/hexview.h

foo: lib all

include parvala.mk

# VALAFILES=hexview.vala main.vala hexviewbuffer.vala
# 
# all:
# 	valac --Xcc=-O3 --pkg gtk+-2.0 hexview.vala main.vala hexviewbuffer.vala
# 
# c:
# 	valac -C --Xcc=-O3 --pkg gtk+-2.0 hexview.vala main.vala hexviewbuffer.vala
# 
lib:
	valac -H ../include/hexview.h --library hexview -Cc --pkg gtk+-2.0 hexview.vala hexviewbuffer.vala
	-cp hexview.vapi ../include
# 	#${CC} -c `pkg-config gtk+-2.0 cairo --cflags` hexview.c
# #	valac --save-temps --pkg gtk+-2.0 HexView.vala
