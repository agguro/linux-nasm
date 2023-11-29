#!/bin/bash
echo "configure ..."
aclocal
autoconf
automake --add-missing --foreign
echo "building ..."
mkdir build
cp redrock.jpg build/
cd build
../configure
make
echo "done."
