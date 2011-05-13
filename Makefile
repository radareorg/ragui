VERSION=`cat VERSION`
R2DIR?=${HOME}/prg/radare2
BINDIST=`pwd`/bindist

all:
	cd src && ${MAKE} widgets.done
	cd src && ${MAKE} all

clean:
	cd src && ${MAKE} clean

setversion:
	mv src/guicore.vala src/guicore.vala.orig
	sed -e "s,string VERSION .*$$,string VERSION = \"${VERSION}\"," < src/guicore.vala.orig > src/guicore.vala
	rm -f src/guicore.vala.orig

mrproper: clean
	cd src/widgets && ${MAKE} clean
	rm -f src/widgets.done
	rm -rf ragui-*

PANGOVERSION=1.6.0
SYSPFX=/opt/local

copyosxlibs:
	for a in `otool -L src/ragui | grep -v libr|grep -v :| awk '{print $$1}'| grep -v System` ; do \
		cp $$a ${BINDIST}/lib ; \
	done
	# missing stuff
	cp ${SYSPFX}/bin/pango-querymodules ${BINDIST}/bin
	cp ${SYSPFX}/bin/gdk-pixbuf-query-loaders ${BINDIST}/bin
	cp ${SYSPFX}/lib/libiconv.2.dylib ${BINDIST}/lib
	cp ${SYSPFX}/lib/libpixman-1.0.dylib ${BINDIST}/lib
	mkdir -p ${BINDIST}/lib/pango/${PANGOVERSION}/modules
	cp ${SYSPFX}/lib/pango/${PANGOVERSION}/modules/*.so \
		${BINDIST}/lib/pango/${PANGOVERSION}/modules

GTKENGINESDIR=/lib/gtk-2.0/2.10.0/engines
GTKPIXBUF=lib/gdk-pixbuf-2.0/2.10.0/loaders/
copyosxtheme:
	mkdir -p ${BINDIST}/${GTKPIXBUF}
	cp ${SYSPFX}/${GTKPIXBUF}/* ${BINDIST}/${GTKPIXBUF}
	mkdir -p ${BINDIST}/${GTKENGINESDIR}
	cp ${SYSPFX}/${GTKENGINESDIR}/libclearlooks.so ${BINDIST}/${GTKENGINESDIR}
	mkdir -p ${BINDIST}/share/themes
	cp -rf ${SYSPFX}/share/themes/Clearlooks ${BINDIST}/share/themes

osxdist:
	rm -rf ${BINDIST}
	mkdir -p ${BINDIST}/bin
	mkdir -p ${BINDIST}/lib
	${MAKE} copyosxlibs
	${MAKE} copyosxtheme
	cp bin/ragui.sh ${BINDIST}/bin/ragui
	cp src/ragui ${BINDIST}/bin/ragui.bin
	BINDIR=`pwd`/bindist ; \
	echo $${BINDIR} ; \
	cd ${R2DIR} ; ${MAKE} install PREFIX=/ DESTDIR=$${BINDIR}
	#rm -rf bindist/lib/libr_*.dylib.*
	rm -rf ragui-${VERSION}
	mv bindist ragui-${VERSION}
	-for a in ragui-${VERSION}/bin/r* ; do strip -s $$a ; done
	#	upx ragui-${VERSION}/bin/ragui.bin
	tar cjvf ragui-${VERSION}.tar.bz2 ragui-${VERSION}

osxapp:
	rm -rf Ragui.app
	mkdir -p Ragui.app/Contents
	cd Ragui.app/Contents ; mkdir MacOS Resources
	tar xzf ragui-${VERSION}.tar.bz2 -C Ragui.app/Contents/Resources
	cd Ragui.app/Contents/Resources ; \
		mv ragui*/* . ; rm -rf ragui*
	cp bin/osx/Ragui Ragui.app/Contents/MacOS/Ragui
	chmod +x Ragui.app/Contents/MacOS/Ragui
	cp bin/osx/PkgInfo bin/osx/Info.plist Ragui.app/Contents
	cp bonus/Ragui.icns Ragui.app/Contents/Resources
	zip -r ragui-osx-${VERSION}.zip Ragui.app
	${MAKE} osxdmg

osxdmg:
	rm -f ragui-${VERSION}.dmg
	# TODO: pass version and so on
	ruby bin/osx/mkdmg Ragui.app
	mv Ragui.app.dmg ragui-${VERSION}.dmg

bindist:
	rm -rf ${BINDIST}
	mkdir -p ${BINDIST}/bin
	mkdir -p ${BINDIST}/lib
	cp /usr/lib/libgmp.so ${BINDIST}/lib
	cp /usr/lib/libgmp.so.10 ${BINDIST}/lib
	cp bin/ragui.sh ${BINDIST}/bin/ragui
	cp src/ragui ${BINDIST}/bin/ragui.bin
	BINDIR=`pwd`/bindist ; \
	echo $${BINDIR} ; \
	cd ${R2DIR} ; ${MAKE} install PREFIX=/ DESTDIR=$${BINDIR}
	rm -rf ragui-${VERSION}
	mv bindist ragui-${VERSION}
	-strip -s ragui-${VERSION}/bin/*
	-strip -s ragui-${VERSION}/lib/*
	upx ragui-${VERSION}/bin/ragui.bin
	tar cjvf ragui-${VERSION}.tar.bz2 ragui-${VERSION}

#TODO: Push on a arch-specific subdir (x86-32, x86-64, powerpc, ...)
push:
	scp src/ragui \
	src/widgets/codew/codew \
	src/widgets/grava/grava \
	src/widgets/grasm/grasm \
	pancake@radare.org:/home/www/radarenopcode/ragui/get

.PHONY: all clean mrproper bindist push

install:
	cp src/ragui ${PREFIX}/bin/ragui.bin
	cp bin/ragui.sh ${PREFIX}/bin/ragui
