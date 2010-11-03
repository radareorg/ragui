CC?=gcc
BIN=ragui
R2DEPS=r_asm r_util r_core
VALAC?=valac
GTKAMLC?=gtkamlc

PKG=--pkg gtk+-2.0 --pkg codeview --pkg hexview
PKG+= --pkg grasmwidget --pkg r_util --pkg r_asm --pkg grava
#GTKAMLFLAGS=--implicitsdir=/usr/share/gtkamlc/implicits/
PKG+=--vapidir=widgets/include
PKG+=--Xcc=-Iwidgets/include
PKG+=--pkg r_core
VALAFLAGS=${PKG}

# TODO: use .a archive files here
WIDGETS=`ls widgets/codew/*.c| grep -v main`
WIDGETS+=widgets/hexview/hexview.c
WIDGETS+=widgets/hexview/hexviewbuffer.c
WIDGETS+=widgets/grasm/grasmwidget.c
WIDGETS+=widgets/grava/*.o

all: widgets.done
	@${MAKE} gtkaml
	@${MAKE} vala
	@${MAKE} link

.PHONY: gtkaml vala

GTKAMLFILES=console.gtkaml mainwindow.gtkaml preferences.gtkaml
VALAFILES=guicore.vala main.vala
RMVALAFILES+=$(subst .gtkaml,.vala,$(GTKAMLFILES))
VALAFILES+=${RMVALAFILES}
CFILES=$(subst .vala,.c,$(VALAFILES))

link:
	@for a in ${CFILES}; do \
		if [ ! -e ${BIN} -o $$a -nt ${BIN} ]; then \
			echo "  CC ${CFILES}" ; \
			${CC} ${CFLAGS} -Iwidgets/include \
				`pkg-config --cflags --libs gtk+-2.0 ${R2DEPS}` \
				${CFILES} ${WIDGETS} -o ${BIN} ; \
			break ; \
		fi ; \
	done

vala:
	@for a in ${VALAFILES}; do \
		c=`echo $$a | sed -e s,vala,c,g` ; \
		if [ ! -e $$c -o $$a -nt $$c ]; then \
			rm -f ${CFILES} ; \
			echo "  VALAC  ${VALAFILES}" ; \
			${VALAC} -C ${VALAFLAGS} ${VALAFILES} ; \
			break ; \
		fi ; \
	done

gtkaml:
	@for a in ${GTKAMLFILES}; do \
		vala=`echo $$a | sed -e s,gtkaml,vala,g` ; \
		if [ ! -e $$vala -o $$a -nt $$vala ]; then \
			echo "  GTKAMLC  ${GTKAMLFILES}" ; \
			rm -f ${RMVALAFILES} ; \
			${GTKAMLC} --save-temps ${PKG} ${GTKAMLFLAGS} -c ${GTKAMLFILES} ; \
			break ; \
		fi ; \
	done

widgets.done:
	#cd widgets/hexview && ${MAKE} lib
	cd widgets/codew && ${MAKE} lib
	cd widgets/grasm && ${MAKE} lib
	cd widgets/grava && ${MAKE} lib
	:> widgets.done

stuff:
	cd widgets && ${MAKE}

clean:
	rm -f ${BIN} *.c *.h ${RMVALAFILES}

clean-widgets:
	cd widgets && ${MAKE} clean
	rm -f widgets.done

mrproper: clean clean-widgets
