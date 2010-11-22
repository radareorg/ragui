CC?=gcc
BIN=ragui
R2DEPS=r_asm r_util r_core
VALAC?=valac
GTKAMLC?=gtkamlc

PKG=--pkg gtk+-2.0 --pkg codeview --pkg hexview --pkg listview
PKG+=--pkg grasmwidget --pkg r_util --pkg r_asm --pkg grava
#Grabin
PKG+=--pkg grabin --pkg grabinsections --pkg grabinsymbols
PKG+=--pkg grabinimports --pkg grabinstrings --pkg grabinrelocs
PKG+=--pkg grabinfat --pkg grabinall --pkg segmentbar
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
WIDGETS+=widgets/listw/listview.c
WIDGETS+=widgets/segmentbar/segmentedbar.c
#Grabin
WIDGETS+=widgets/grabin/grabin.c widgets/grabin/grabinsections.c
WIDGETS+=widgets/grabin/grabinsymbols.c widgets/grabin/grabinimports.c
WIDGETS+=widgets/grabin/grabinstrings.c widgets/grabin/grabinrelocs.c
WIDGETS+=widgets/grabin/grabinfat.c widgets/grabin/grabinall.c

all: widgets.done
	@${MAKE} vapi
	@${MAKE} gtkon
	@${MAKE} vala
	#@${MAKE} gtkaml
	@${MAKE} link

.PHONY: gtkaml gtkon vala vapi link

GTKONFILES=newproject.gtkon openfile.gtkon openproject.gtkon preferences.gtkon console.gtkon
GTKONFILES+=mainbody.gtkon mainpanel.gtkon mainwindow.gtkon openprogram.gtkon openprocess.gtkon
GTKONFILES+=openremote.gtkon dumpdata.gtkon
# TODO: GTKONFILES+=datadump.gtkon
GTKAMLFILES=
VALAFILES=guicore.vala main.vala
RMVALAFILES+=$(subst .gtkaml,.vala,$(GTKAMLFILES))
RMGTKON_FILES+=$(subst .gtkon,.vala,$(GTKONFILES))
GTKAML_C_FILES+=$(subst .gtkaml,.c,$(GTKAMLFILES))
GTKON_C_FILES+=$(subst .gtkon,.c,$(GTKONFILES))
GTKON_C_FILES+=mainwindow.c
VALAFILES+=${RMVALAFILES}
VALAFILES+=${RMGTKON_FILES}
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

vapi:
	valac --fast-vapi guicore.vapi guicore.vala --pkg r_core -C

vala:
	@for a in ${VALAFILES}; do \
		c=`echo $$a | sed -e s,vala,c,g` ; \
		if [ ! -e $$c -o $$a -nt $$c ]; then \
			rm -f ${BIN} ${CFILES} ; \
			echo "  VALAC  ${VALAFILES}" ; \
			${VALAC} -C ${VALAFLAGS} ${VALAFILES} ; \
			break ; \
		fi ; \
	done

gtkon:
	@for a in ${GTKONFILES}; do \
		vala=`echo $$a | sed -e s,gtkon,vala,g` ; \
		if [ ! -e $$vala -o $$a -nt $$vala ]; then \
			echo "  GTKAMLC  ${GTKONFILES}" ; \
			rm -f ${BIN} ${GTKON_C_FILES} ; \
			${GTKAMLC} -V ${PKG} ${GTKAMLFLAGS} ${GTKONFILES} ; \
			break ; \
		fi ; \
	done

GTKAMLFLAGS+=--vapidir=. --pkg guicore
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
	cd widgets/listw && ${MAKE} lib
	cd widgets/grabin && ${MAKE} lib
	:> widgets.done

stuff:
	cd widgets && ${MAKE}

clean:
	rm -f ${BIN} *.c *.h ${RMVALAFILES} ${RMGTKON_FILES}
	rm -f guicore.vapi

clean-widgets:
	cd widgets && ${MAKE} clean
	rm -f widgets.done

mrproper: clean clean-widgets

test:
	#gtkaml --define=MAIN openproject.gtkon
	#gtkaml --define=MAIN mainpanel.gtkon
	gtkaml --define=MAIN openfile.gtkon
	#gtkaml --define=MAIN newproject.gtkon
