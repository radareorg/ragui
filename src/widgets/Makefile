RANLIB?=ranlib

MODS=bugdialog segmentbar gracalc grava grasm codeview hexview listview grabin mounts gradiff texttagview
.PHONY: ${MODS}

all: incdir ${MODS}

incdir:
	@-[ ! -d include ] && mkdir -p include

${MODS}:
	@cd $@ && ${MAKE} lib

ranlib:
	for a in */*.a ; do ${RANLIB} $$a ; done

clean:
	rm -f include/*
	for a in ${MODS} ; do \
		( cd $$a && ${MAKE} clean ) ; \
	done
