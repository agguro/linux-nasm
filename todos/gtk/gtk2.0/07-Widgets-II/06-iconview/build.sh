#!/bin/bash
echo "configure ..."
aclocal
autoconf
automake --add-missing --foreign
echo "building ..."
mkdir build
cp ubuntu.png build/
cp blender.png build/
cp gnumeric.png build/
cp inkscape.png build/
cd build
../configure
make
echo "done."
