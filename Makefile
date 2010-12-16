VERSION=0.1b
R2DIR?=${HOME}/prg/radare2
BINDIST=`pwd`/bindist

all:
	cd src && ${MAKE} widgets.done
	cd src && ${MAKE} all

clean:
	cd src && ${MAKE} clean

mrproper: clean
	cd src/widgets && ${MAKE} clean
	rm -rf ragui-*

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
