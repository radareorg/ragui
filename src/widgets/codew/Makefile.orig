VALAFLAGS=--pkg gtk+-2.0 --pkg cairo

SOURCES=codecontext.vala codejump.vala codeline.vala codeview.vala

all: lib
	valac --Xcc=-I../include ${VALAFLAGS} ${SOURCES} cmain.c -o codew
#	${CC} -c `pkg-config gtk+-2.0 cairo --cflags` $(SOURCES:.vala=.c)
	#${CC} -I../include `pkg-config gtk+-2.0 cairo --cflags --libs` cmain.c $(SOURCES:.vala=.o) -o codew

lib:
	-valac -H ../include/codeview.h --library codew -Cc ${VALAFLAGS} *.vala
	cp codew.vapi ../include
	${CC} -c `pkg-config gtk+-2.0 cairo --cflags` $(SOURCES:.vala=.c)

clean:
	mv cmain.c __
	rm -f *.c *.h *.o a.out codew
	mv __ cmain.c
