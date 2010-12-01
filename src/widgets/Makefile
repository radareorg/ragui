all:
	mkdir -p include
	cd grava && ${MAKE} lib
	cd grasm && ${MAKE} lib
	cd codew && ${MAKE} lib
	cd hexview && ${MAKE} lib
	cd listw && ${MAKE} lib
	cd grabin && ${MAKE} lib
	#-cd include && valac -C --pkg gtk+-2.0 --pkg cairo ../codew/*.vala --library codew
	#-cd include && valac -C --pkg gtk+-2.0 --pkg cairo ../grava/*.vala --library grava

clean:
	rm -f include/*
	cd codew && ${MAKE} clean
	cd grava && ${MAKE} clean
	cd grasm && ${MAKE} clean
	cd grabin && ${MAKE} clean
