CC?=gcc
BIN=ragui
R2DEPS=r_asm r_util r_core
VALAC?=valac
GTKAMLC?=gtkamlc

PKG=--pkg gtk+-2.0 --pkg codeview --pkg hexview --pkg listview
PKG+=--pkg grasmwidget --pkg r_util --pkg r_asm --pkg grava
# TODO grabin packages.. must be merged
PKG+=--pkg grabin --pkg grabinsections --pkg grabinsymbols
PKG+=--pkg grabinimports --pkg grabinstrings --pkg grabinrelocs
PKG+=--pkg grabinfat --pkg grabinall --pkg segmentbar --pkg texttagview
#GTKAMLFLAGS=--implicitsdir=/usr/share/gtkamlc/implicits/
PKG+=--vapidir=widgets/include
PKG+=--Xcc=-Iwidgets/include
PKG+=--pkg r_core
VALAFLAGS=${PKG} --thread

WIDGETS+=widgets/grava/libgrava.a
WIDGETS+=widgets/codew/libcodew.a
WIDGETS+=widgets/hexview/libhexview.a
WIDGETS+=widgets/grabin/libgrabin.a
WIDGETS+=widgets/grasm/libgrasm.a
WIDGETS+=widgets/listw/liblistw.a
WIDGETS+=widgets/segmentbar/libsegbar.a
WIDGETS+=widgets/texttagview/libtexttagview.a

all: widgets.done
	@${MAKE} vapi
	@${MAKE} gtkon
	@${MAKE} vala
	@${MAKE} link

.PHONY: gtkaml gtkon vala vapi link widgets

GTKONFILES=scriptwidget.gtkon searchwidget.gtkon disasm.gtkon newproject.gtkon openfile.gtkon
GTKONFILES+=debugwidget.gtkon openproject.gtkon preferences.gtkon console.gtkon
GTKONFILES+=mainbody.gtkon mainpanel.gtkon mainwindow.gtkon openprogram.gtkon openprocess.gtkon
GTKONFILES+=openremote.gtkon dumpdata.gtkon analyze.gtkon
# TODO: GTKONFILES+=datadump.gtkon
VALAFILES=guicore.vala main.vala
RMGTKON_FILES+=$(subst .gtkon,.vala,$(GTKONFILES))
GTKON_C_FILES+=$(subst .gtkon,.c,$(GTKONFILES))
GTKON_C_FILES+=mainwindow.c
VALAFILES+=${RMVALAFILES}
VALAFILES+=${RMGTKON_FILES}
CFILES=$(subst .vala,.c,$(VALAFILES))
OFILES=$(subst .vala,.o,$(VALAFILES))

CFLAGS+=-Iwidgets/include `pkg-config --cflags gtk+-2.0 ${R2DEPS}`
link: ${OFILES}
	@for a in ${CFILES}; do \
		if [ ! -e ${BIN} -o $$a -nt ${BIN} ]; then \
			echo "  CC ${OFILES}" ; \
			echo "  LD ragui" ; \
			${CC} ${CFLAGS} -Iwidgets/include \
				`pkg-config --cflags --libs gthread-2.0 gtk+-2.0 ${R2DEPS}` \
				${OFILES} ${WIDGETS} -o ${BIN} ; \
			break ; \
		fi ; \
	done

guicore:
	valac --define=TEST guicore.vala --pkg r_core --pkg gtk+-2.0

vapi:
	valac --fast-vapi guicore.vapi guicore.vala --pkg r_core -C

vala:
	@for a in ${VALAFILES}; do \
		c=`echo $$a | sed -e s,vala,c,g` ; \
		if [ ! -e $$c -o $$a -nt $$c ]; then \
			rm -f ${BIN} ${CFILES} ; \
			echo "  VALAC  ${VALAFILES}" ; \
			${VALAC} -C ${VALAFLAGS} ${VALAFILES} ; \
			exit $? ; \
		fi ; \
	done

gtkon:
	@for a in ${GTKONFILES}; do \
		vala=`echo $$a | sed -e s,gtkon,vala,g` ; \
		if [ ! -e $$vala -o $$a -nt $$vala ]; then \
			echo "  GTKAMLC  ${GTKONFILES}" ; \
			rm -f ${BIN} ${GTKON_C_FILES} ; \
			${GTKAMLC} -V ${PKG} ${GTKAMLFLAGS} ${GTKONFILES} ; \
			exit $? ; \
		fi ; \
	done

# hacky..conflicts with widgets:
widgets.done:
	cd widgets && ${MAKE}
	:> widgets.done

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

widgets:
	cd widgets && ${MAKE} all

install:
	cp src/ragui ${PREFIX}/bin/ragui.bin
	cp bin/ragui.sh ${PREFIX}/bin/ragui
