#!/bin/sh
# ragui launcher
R2DIR=$(dirname $0)/..
echo "Starting ragui from ${R2DIR}.."
LD_LIBRARY_PATH=${R2DIR}/lib
LIBR_PLUGINS=${R2DIR}/plugins
PKG_CONFIG_PATH=${R2DIR}/lib/pkgconfig
export LD_LIBRARY_PATH LIBR_PLUGINS PKG_CONFIG_PATH
${R2DIR}/bin/ragui.bin $@
