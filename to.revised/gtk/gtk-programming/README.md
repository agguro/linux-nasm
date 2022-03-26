# gtk-programming
all examples from http://zetcode.com/gui/gtk2/ in Nasm on Linux and more.


The following libraries and tools need to be installed, development versions or the normal
versions, as you like:

Nasm: version 13 and above
LD:	GNU linker
GTK2+
GTK3+
GLib
Pango
ATK
GDK
GdkPixbuf
Cairo

To build the examples:

mkdir build
cd build
../configure
make

or use the build.sh script.

When only sourcecode is available you can do it the 'old way'

    nasm -f elf64 -F dwarf -g progname.asm -o progname.o
    for GTK2+ examples
        ld -m elf_x86_64 -g --dynamic-linker /lib64/ld-linux-x86-64.so.2 -lc `pkg-config --libs gtk+-2.0` progname.o -o progname
    or
    for GTK3+ examples
        ld -m elf_x86_64 -g --dynamic-linker /lib64/ld-linux-x86-64.so.2 -lc `pkg-config --libs gtk+-3.0` progname.o -o progname

