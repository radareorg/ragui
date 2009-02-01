VALAFLAGS=--pkg gtk+-2.0 --pkg cairo

all:
	valac -C ${VALAFLAGS} *.vala
	${CC} `pkg-config gtk+-2.0 cairo --cflags --libs` cmain.c $(SOURCES:.vala=.o) -o a.out

clean:
	mv cmain.c __
	rm -f *.c *.h *.o a.out
	mv __ cmain.c
