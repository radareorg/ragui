PKG=--pkg gtk+-2.0 --pkg codew --pkg hexview --pkg grasmwidget --pkg r_util --pkg r_asm
R2DEPS=r_asm r_util
BIN=ragui
#AML=--implicitsdir=/usr/share/gtkamlc/implicits/
#PKG+=-C --save-temps
PKG+=--vapidir=widgets/include
PKG+=--save-temps
PKG+=--Xcc=-Iwidgets/include
WIDGETS=widgets/codew/*.o
WIDGETS+=widgets/hexview/hexview.c
WIDGETS+=widgets/hexview/hexviewbuffer.c
WIDGETS+=widgets/grasm/grasmwidget.c
WIDGETS+=widgets/grava/*.o
CC?=gcc

all: libs
	gtkamlc ${PKG} ${AML} -c console.gtkaml mainwindow.gtkaml preferences.gtkaml
	valac --Xcc=-O3 -c ${PKG} *.vala
	${CC} -Iwidgets/include -O3 `pkg-config --cflags --libs gtk+-2.0 ${R2DEPS}` *.o ${WIDGETS} -o ${BIN}

libs:
	cd widgets/hexview && ${MAKE} lib
	cd widgets/codew && ${MAKE} lib
	cd widgets/grasm && ${MAKE} lib

c:
	gtkamlc ${AML} -C ${PKG} console.gtkaml mainwindow.gtkaml preferences.gtkaml

stuff:
	cd widgets && ${MAKE}

clean:
	cd widgets && ${MAKE} clean
	rm -f ${BIN} *.c *.h mainwindow.vala *.o preferences.vala
