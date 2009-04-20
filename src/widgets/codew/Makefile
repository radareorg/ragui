VALAFLAGS=--pkg gtk+-2.0 --pkg cairo

SOURCES=codecontext.vala codejump.vala codeline.vala codewidget.vala

all:
	-valac -H ../include/codewidget.h --library codew -Cc ${VALAFLAGS} *.vala
	${CC} -c `pkg-config gtk+-2.0 cairo --cflags` $(SOURCES:.vala=.c)
	cp codew.vapi ../include
	${CC} -I../include `pkg-config gtk+-2.0 cairo --cflags --libs` cmain.c $(SOURCES:.vala=.o) -o a.out

clean:
	mv cmain.c __
	rm -f *.c *.h *.o a.out
	mv __ cmain.c
