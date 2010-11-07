#!/bin/sh
#
# cd /usr/bin && sudo ln -s ragui.sh
#
R2DIR=$(dirname $0)/..
echo "Starting ragui from ${R2DIR}.."
LD_LIBRARY_PATH=${R2DIR}/lib
LIBR_PLUGINS=${R2DIR}/plugins
export LD_LIBRARY_PATH LIBR_PLUGINS
cd ${R2DIR}/src
./ragui
