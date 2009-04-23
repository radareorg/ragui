all:
	cd src && ${MAKE} stuff
	cd src && ${MAKE} all

clean:
	cd src && ${MAKE} clean

#TODO: Push on a arch-specific subdir (x86-32, x86-64, powerpc, ...)
push:
	scp src/ragui \
	src/widgets/codew/codew \
	src/widgets/grava/grava \
	src/widgets/grasm/grasm \
	pancake@radare.org:/home/www/radarenopcode/ragui/get
