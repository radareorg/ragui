PKG=--pkg gtk+-2.0 --pkg codeview --pkg hexview
PKG+= --pkg grasmwidget --pkg r_util --pkg r_asm --pkg grava
R2DEPS=r_asm r_util
BIN=ragui
#AML=--implicitsdir=/usr/share/gtkamlc/implicits/
#PKG+=-C --save-temps
PKG+=--vapidir=widgets/include
PKG+=--save-temps
PKG+=--Xcc=-Iwidgets/include
WIDGETS=`ls widgets/codew/*.c| grep -v main`
WIDGETS+=widgets/hexview/hexview.c
WIDGETS+=widgets/hexview/hexviewbuffer.c
WIDGETS+=widgets/grasm/grasmwidget.c
WIDGETS+=widgets/grava/*.o
CC?=gcc

all: widgets.done
	gtkamlc ${PKG} ${AML} -c console.gtkaml mainwindow.gtkaml preferences.gtkaml
	valac --Xcc=-O3 -c ${PKG} *.vala
	${CC} -Iwidgets/include -O3 `pkg-config --cflags --libs gtk+-2.0 ${R2DEPS}` *.o ${WIDGETS} -o ${BIN}

widgets.done:
	#cd widgets/hexview && ${MAKE} lib
	cd widgets/codew && ${MAKE} lib
	cd widgets/grasm && ${MAKE} lib
	cd widgets/grava && ${MAKE} lib
	:> widgets.done

c:
	gtkamlc ${AML} -C ${PKG} console.gtkaml mainwindow.gtkaml preferences.gtkaml

stuff:
	cd widgets && ${MAKE}

clean:
	cd widgets && ${MAKE} clean
	rm -f ${BIN} *.c *.h mainwindow.vala *.o preferences.vala
	rm -f widgets.done
