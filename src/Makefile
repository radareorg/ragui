CC?=gcc
BIN=ragui
#BIN=ragui.exe
R2DEPS=r_asm r_util r_core r_socket
VALAC?=valac
GTKAMLC?=gtkamlc
MD5=./chkts
#MD5=md5sum

PKG=--pkg gtk+-2.0 --pkg codeview --pkg hexview --pkg listview
PKG+=--pkg grasmwidget --pkg r_util --pkg r_asm --pkg grava --pkg bugdialog
PKG+=--pkg posix
# TODO grabin packages.. must be merged
PKG+=--pkg grabin --pkg grabinsections --pkg grabinsymbols --pkg gracalc
PKG+=--pkg grabinimports --pkg grabinstrings --pkg grabinrelocs --pkg mounts
PKG+=--pkg grabinfat --pkg grabinall --pkg segmentbar --pkg texttagview --pkg gradiff
#GTKAMLFLAGS=--implicitsdir=/usr/share/gtkamlc/implicits/
PKG+=--vapidir=widgets/include
PKG+=--Xcc=-Iwidgets/include
PKG+=--pkg r_core
VALAFLAGS=${PKG} --thread

#PACKAGES=bugdialog
#PKGMKS=$(addprefix --pkg ,${PACKAGES})
#WIDGETS+=...

WIDGETS+=widgets/bugdialog/libbugdialog.a
WIDGETS+=widgets/gradiff/libgradiff.a
WIDGETS+=widgets/grava/libgrava.a
WIDGETS+=widgets/gracalc/libgracalc.a
WIDGETS+=widgets/codeview/libcodeview.a
WIDGETS+=widgets/hexview/libhexview.a
WIDGETS+=widgets/grabin/libgrabin.a
WIDGETS+=widgets/listview/liblistview.a
WIDGETS+=widgets/segmentbar/libsegmentbar.a
WIDGETS+=widgets/texttagview/libtexttagview.a
WIDGETS+=widgets/grasm/libgrasm.a
WIDGETS+=widgets/mounts/libmounts.a

all: widgets.done
	@${MAKE} vapi
	@${MAKE} tstamp_begin
	@${MAKE} gtkon
	@${MAKE} vala
	@${MAKE} tstamp_end
	@${MAKE} link

.PHONY: gtkaml gtkon vala vapi link widgets

GTKONFILES=seekstack.gtkon signatures.gtkon
GTKONFILES+=scriptwidget.gtkon searchwidget.gtkon disasm.gtkon newproject.gtkon openfile.gtkon
GTKONFILES+=debugwidget.gtkon openproject.gtkon preferences.gtkon console.gtkon flagswidget.gtkon
GTKONFILES+=bodyeditor.gtkon mainpanel.gtkon mainwindow.gtkon openprogram.gtkon openprocess.gtkon
GTKONFILES+=openremote.gtkon dumpdata.gtkon analyze.gtkon editasm.gtkon
GTKONFILES+=bodydebugger.gtkon bodybindiff.gtkon bodyforensics.gtkon
# TODO: GTKONFILES+=datadump.gtkon
OVALAFILES=guicore.vala guiconfig.vala main.vala
VALAFILES=${OVALAFILES}
RMGTKON_FILES+=$(subst .gtkon,.vala,$(GTKONFILES))
GTKON_C_FILES+=$(subst .gtkon,.c,$(GTKONFILES))
GTKON_C_FILES+=mainwindow.c
VALAFILES+=${RMVALAFILES}
VALAFILES+=${RMGTKON_FILES}
CFILES=$(subst .vala,.c,$(VALAFILES))
OFILES=$(subst .c,.o,$(CFILES))
OFILES+=img/images.o
CFLAGS+=-Iwidgets/include `pkg-config --cflags gtk+-2.0 ${R2DEPS}`

include ../config.mk

ifeq ($(DEBUG),1)
CFLAGS+=-g
# vala level debug -- VALAFLAGS+=-g
# c level debug
VALAFLAGS+=-X -g
endif

%.o:%.c
	@echo "  CC -c $<"
	@${CC} ${CFLAGS} -c $<

link: ${OFILES}
	@for a in ${CFILES}; do \
		if [ ! -e ${BIN} -o $$a -nt ${BIN} ]; then \
			echo "  CC ${OFILES}" ; \
			echo "  LD ragui" ; \
			${CC} ${CFLAGS} -Iwidgets/include ${OFILES} ${WIDGETS}  \
				`pkg-config --cflags --libs gthread-2.0 gtk+-2.0 ${R2DEPS}` \
				${LDFLAGS} -o ${BIN} ; \
			break ; \
		fi ; \
	done

#guicore:
#	valac --define=TEST guicore.vala --pkg r_core --pkg gtk+-2.0

vapi:
	echo "  CC guicore.vapi" ; \
	valac --thread --library guicore \
		--vapi widgets/include/guicore.vapi -H widgets/include/guicore.h \
		guicore.vala --pkg r_core --pkg gtk+-2.0 -C

tstamp_begin:
	@${MD5} *.gtkon ${OVALAFILES} | sed -e s,gtkon,c,g -e s,vala,c,g | tr '()' '  ' | awk '{print " "$$4" "$$2}' > .tstamp 2>/dev/null
	@#-wc -c *.c > .tstamp

tstamp_end:
	@${MD5} *.gtkon ${OVALAFILES} | sed -e s,gtkon,c,g -e s,vala,c,g | tr '()' '  ' | awk '{print " "$$4" "$$2}' > .tstamp2 2>/dev/null
	@#-wc -c *.c > .tstamp2
	@-if [ -e .tstamp ]; then \
	[ -e main.o ] && touch *.o ; \
	rm -f `diff -U 1 .tstamp .tstamp2 | grep ^+ | grep c$$ | awk '{print $$3}'|sed -e 's,c$$,o,'` ; \
	fi

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
		vala=`echo $$a | sed -e s,gtkon,o,g` ; \
		if [ ! -e $$vala -o $$a -nt $$vala ]; then \
			echo "  GTKAMLC  ${GTKONFILES}" ; \
			echo "  RM  ragui $${vala}" ; \
			rm -f $${vala} ${BIN} ${GTKON_C_FILES} ; \
			${GTKAMLC} -C ${PKG} ${GTKAMLFLAGS} ${GTKONFILES} ; \
			exit $? ; \
		fi ; \
	done

# hacky..conflicts with widgets:
widgets.done:
	${MAKE} vapi
	cd widgets && ${MAKE}
	cd img && ${MAKE}
	:> widgets.done

clean:
	rm -f ${BIN} *.o *.c *.h ${RMVALAFILES} ${RMGTKON_FILES}
	rm -f guicore.vapi .tstamp .tstamp2

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
