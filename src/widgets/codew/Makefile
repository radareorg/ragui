VALAFLAGS=--pkg gtk+-2.0 --pkg cairo

SOURCES=codecontext.vala codejump.vala codeline.vala codewidget.vala

all:
	valac -C ${VALAFLAGS} *.vala
	-valac -c ${VALAFLAGS} *.vala
	${CC} `pkg-config gtk+-2.0 cairo --cflags --libs` cmain.c $(SOURCES:.vala=.c) -o a.out

clean:
	mv cmain.c __
	rm -f *.c *.h *.o a.out
	mv __ cmain.c
