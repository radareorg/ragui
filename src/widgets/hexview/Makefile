VALAFILES=hexview.vala hexviewbuffer.vala main.vala
VALAFLAGS=--pkg gtk+-2.0
OUT_BIN=hexview
OUT_HFILE=../include/hexviewbuffer.h

.PHONY: main lib

main: lib all

lib: $(OUT_HFILE)
	#@cp .vala-aux/hexview*.vapi ../include/
	valac --vapi ../include/hexview.vapi --library hexview -Cc --pkg gtk+-2.0 hexviewbuffer.vala hexview.vala
	#cp hexview.vapi ../include

include ../parvala.mk


# VALAFILES=hexview.vala main.vala hexviewbuffer.vala
# 
# all:
# 	valac --Xcc=-O3 --pkg gtk+-2.0 hexview.vala main.vala hexviewbuffer.vala
# 
# c:
# 	valac -C --Xcc=-O3 --pkg gtk+-2.0 hexview.vala main.vala hexviewbuffer.vala
# 

#foola:
#	@if [ hexview.vala -nt ../include/hexview.h ]; then \
#	echo "  HDR    ../include/hexview.h" ; \
#	valac -H ../include/hexview.h --library hexview -Cc --pkg gtk+-2.0 hexview.vala hexviewbuffer.vala ; \
#	cp hexview.vapi ../include ; \
#	fi
# 	#${CC} -c `pkg-config gtk+-2.0 cairo --cflags` hexview.c
# #	valac --save-temps --pkg gtk+-2.0 HexView.vala
