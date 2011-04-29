#!/bin/sh
# ragui launcher -- pancake // 2011
R2DIR=$(dirname "$0")/..
echo "Starting ragui from ${R2DIR}.."
DYLD_LIBRARY_PATH="${R2DIR}/lib:/tmp/lib"

# OS specific stuff
case `uname` in
Darwin)
	# TODO: Use temporal-directory to scan and store pango.{rc|modules}
	DYLD_LIBRARY_PATH="${R2DIR}/lib"
	export DYLD_LIBRARY_PATH
	PANGO_RC_FILE=${TMPDIR}/etc/pango.rc
	mkdir -p ${TMPDIR}/etc
	export PANGO_RC_FILE
	echo "[Pango]" > ${PANGO_RC_FILE}
	echo "ModuleFiles = ${TMPDIR}/etc/pango.modules" >> ${PANGO_RC_FILE}
	PANGOVERSION=1.6.0
	"${R2DIR}/bin/pango-querymodules" \
		"${R2DIR}/lib/pango/${PANGOVERSION}/modules/"pango-*.so > \
		${TMPDIR}/etc/pango.modules
	;;
*)
	LD_LIBRARY_PATH="${R2DIR}/lib:/tmp/lib"
	export LD_LIBRARY_PATH
	;;
esac

LIBR_PLUGINS=${R2DIR}/plugins
PKG_CONFIG_PATH=${R2DIR}/lib/pkgconfig
export LIBR_PLUGINS PKG_CONFIG_PATH
exec "${R2DIR}/bin/ragui.bin" $@
