all:
	mkdir -p include
	cd grava && ${MAKE}
	cd grasm && ${MAKE}
	cd codew && ${MAKE}
	cd hexview && ${MAKE}
	#-cd include && valac -C --pkg gtk+-2.0 --pkg cairo ../codew/*.vala --library codew
	#-cd include && valac -C --pkg gtk+-2.0 --pkg cairo ../grava/*.vala --library grava

clean:
	rm -f include/*
	cd codew && ${MAKE} clean
	cd grava && ${MAKE} clean
	cd grasm && ${MAKE} clean
