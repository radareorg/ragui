#!/bin/sh
# ragui launcher -- pancake // 2011
R2DIR=$(dirname "$0")/..
echo "Starting ragui from ${R2DIR}.."
DYLD_LIBRARY_PATH="${R2DIR}/lib:/tmp/lib"
PATH="${R2DIR}/bin:${PATH}"

# Force GTK Theme
force_gtk_theme() {
	GDK_PIXBUF_MODULE_FILE="${R2DIR}/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache"
	gdk-pixbuf-query-loaders > ${GDK_PIXBUF_MODULE_FILE}
	export GDK_PIXBUF_MODULE_FILE
	GTK_PATH="${R2DIR}/lib/gtk-2.0"
	export GTK_PATH
	XDG_DATA_DIRS="${R2DIR}/share"
	export XDG_DATA_DIRS
	GTK2_RC_FILES=${TMPDIR}/etc/gtkrc-2.0
	export GTK2_RC_FILES
	echo > ${GTK2_RC_FILES}
	#echo "pixmap_path \"${R2DIR}/share/themes/\"" > ${GTK2_RC_FILES}
	echo "include \"${R2DIR}/share/themes/Clearlooks/gtk-2.0/gtkrc\"" >> ${GTK2_RC_FILES}
	echo >> ${GTK2_RC_FILES} <<EOF
style "font" {
	font_name = "Verdana 12"
}

widget_class "*" style "font"
gtk-font-name = "Verdana 12"
EOF
}

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
	force_gtk_theme
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
