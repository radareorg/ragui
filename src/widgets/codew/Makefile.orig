VALAFILES=codecontext.vala codejump.vala codeline.vala codeview.vala
CFILES=cmain.c
VALAFLAGS=--pkg gtk+-2.0 --Xcc=-I../include
OUT_BIN=codew
OUT_HFILE=../include/codeview.h

.PHONY: main lib

main: lib all

lib: ../include/codeview.h
	valac -C --library codeview --vapi=../include/codeview.vapi ${VALAFLAGS} ${VALAFILES} -H ../include/codeview.h
	#cp *.h
	#@cp -f .vala-aux/codeview.vapi ../include

include ../parvala.mk


# VALAFILES=codew.vala main.vala codewbuffer.vala
# 
# all:
# 	valac --Xcc=-O3 --pkg gtk+-2.0 codew.vala main.vala codewbuffer.vala
# 
# c:
# 	valac -C --Xcc=-O3 --pkg gtk+-2.0 codew.vala main.vala codewbuffer.vala
# 

#foola:
#	@if [ codew.vala -nt ../include/codew.h ]; then \
#	echo "  HDR    ../include/codew.h" ; \
#	valac -H ../include/codew.h --library codew -Cc --pkg gtk+-2.0 codew.vala codewbuffer.vala ; \
#	cp codew.vapi ../include ; \
#	fi
# 	#${CC} -c `pkg-config gtk+-2.0 cairo --cflags` codew.c
# #	valac --save-temps --pkg gtk+-2.0 HexView.vala
