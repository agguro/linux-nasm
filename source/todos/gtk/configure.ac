AC_PREREQ([2.69])

AC_INIT([simple], [1.0.0], [aggurobe@gmail.com], [hello],[https://linuxnasm.be])

AX_PROG_NASM([nasm_avail="no"])

PACKAGE_LDFLAGS="-g -melf_x86_64 -g --dynamic-linker /lib64/ld-linux-x86-64.so.2"
PACKAGE_NASMFLAGS="-f elf64 -F dwarf -g"
PACKAGE_LIBS="-lc -lgtk-3 -lgobject-2.0 -lgdk-3"
PACKAGE_INC="-I../gtkapp.class"

AC_SUBST([PACKAGE_LDFLAGS])
AC_SUBST([PACKAGE_NASMFLAGS])
AC_SUBST([PACKAGE_LIBS])
AC_SUBST([PACKAGE_INC])

AM_INIT_AUTOMAKE(foreign)

AC_CONFIG_FILES(Makefile)
AC_OUTPUT
