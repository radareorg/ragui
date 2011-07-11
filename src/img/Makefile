all:
	gdk-pixbuf-csource rlogo.png --name=rlogo_pixmap > rlogo.h
	${CC} -c `pkg-config gtk+-2.0 --cflags` images.c

clean:
	rm rlogo.h
