RANLIB?=ranlib

all:
	mkdir -p include
	cd bugdialog && ${MAKE} lib
	cd segmentbar && ${MAKE} lib
	cd gracalc && ${MAKE} lib
	cd grava && ${MAKE} lib
	cd gracalc && ${MAKE} lib
	cd grasm && ${MAKE} lib
	cd codew && ${MAKE} lib
	cd hexview && ${MAKE} lib
	cd listw && ${MAKE} lib
	cd grabin && ${MAKE} lib
	cd mounts && ${MAKE} lib
	cd gradiff && ${MAKE} lib
	cd texttagview && ${MAKE} lib

ranlib:
	for a in */*.a ; do ${RANLIB} $$a ; done

clean:
	rm -f include/*
	cd segmentbar && ${MAKE} clean
	cd grava && ${MAKE} clean
	cd gracalc && ${MAKE} clean
	cd grasm && ${MAKE} clean
	cd codew && ${MAKE} clean
	cd gracalc && ${MAKE} clean
	cd hexview && ${MAKE} clean
	cd listw && ${MAKE} clean
	cd grabin && ${MAKE} clean
	cd mounts && ${MAKE} clean
	cd gradiff && ${MAKE} clean
	cd texttagview && ${MAKE} clean
