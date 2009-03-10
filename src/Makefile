PKG=--pkg gtk+-2.0 --pkg codew
BIN=ragui
#AML=--implicitsdir=/usr/share/gtkamlc/implicits/
#PKG+=-C --save-temps
PKG+=--vapidir=widgets/include
PKG+=--save-temps
PKG+=--Xcc=-Iwidgets/include
WIDGETS=widgets/codew/*.o
CC?=gcc

all:
	cd widgets && ${MAKE}
	cd widgets/codew && ${MAKE}
	#cd widgets && ${MAKE}
	gtkamlc ${AML} -c ${PKG} console.gtkaml mainwindow.gtkaml preferences.gtkaml
	#valac ${PKG} *.vala ${WIDGETS} -o ${BIN}
	valac -c ${PKG} *.vala
	${CC} `pkg-config --cflags --libs gtk+-2.0` *.o ${WIDGETS} -o ${BIN}

clean:
	rm -f ${BIN} *.c *.h mainwindow.vala *.o preferences.vala
	cd widgets && ${MAKE} clean
