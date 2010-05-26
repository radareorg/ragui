PKG=--pkg gtk+-2.0 --pkg codew --pkg hexview
BIN=ragui
#AML=--implicitsdir=/usr/share/gtkamlc/implicits/
#PKG+=-C --save-temps
PKG+=--vapidir=widgets/include
PKG+=--save-temps
PKG+=--Xcc=-Iwidgets/include
WIDGETS=widgets/codew/*.o
WIDGETS+=widgets/hexview/hexview.c
WIDGETS+=widgets/hexview/hexviewbuffer.c
CC?=gcc

all:
	gtkamlc ${AML} -c ${PKG} console.gtkaml mainwindow.gtkaml preferences.gtkaml
	valac -c ${PKG} *.vala
	${CC} `pkg-config --cflags --libs gtk+-2.0` *.o ${WIDGETS} -o ${BIN}

c:
	gtkamlc ${AML} -C ${PKG} console.gtkaml mainwindow.gtkaml preferences.gtkaml

stuff:
	cd widgets && ${MAKE}

clean:
	cd widgets && ${MAKE} clean
	rm -f ${BIN} *.c *.h mainwindow.vala *.o preferences.vala
