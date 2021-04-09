#! /bin/sh
touch AUTHORS NEWS README ChangeLog
aclocal
automake --add-missing --foreign --copy
autoconf
./configure --bindir=$PWD/../build/X11/
make
make install