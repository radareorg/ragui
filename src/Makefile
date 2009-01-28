PKG=--pkg gtk+-2.0
BIN=ragui
#AML=--implicitsdir=/usr/share/gtkamlc/implicits/
#PKG+=-C --save-temps
PKG+=--save-temps

all:
	gtkamlc ${AML} -c ${PKG} mainwindow.gtkaml
	valac ${PKG} *.vala -o ${BIN}

clean:
	rm -f ${BIN}
