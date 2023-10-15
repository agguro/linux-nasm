#!/bin/bash
echo "configure ..."
aclocal
autoconf
automake --add-missing --foreign
echo "building ..."
mkdir build
cp icon.png build/
cd build
../configure
make
echo "done."
