all:
	-cd include && valac --pkg gtk+-2.0 --pkg cairo ../codew/*.vala --library codew 2>/dev/null
	-cd include && valac --pkg gtk+-2.0 --pkg cairo ../grava/*.vala --library grava 2>/dev/null

clean:
	rm -f include/*
	cd codew && ${MAKE} clean
	cd grava && ${MAKE} clean
