AC_PREREQ([2.69])

AC_INIT([hello], [1.0.0], [aggurobe@gmail.com], [hello],[https://linuxnasm.be])

#AC_INIT([FULL-PACKAGE-NAME], [VERSION], [BUG-REPORT-ADDRESS], [TAR-NAME],[URL])
#AC_PACKAGE_NAME, PACKAGE_NAME       Exactly package.
#AC_PACKAGE_TARNAME, PACKAGE_TARNAME Exactly tarname, possibly generated from package.
#AC_PACKAGE_VERSION, PACKAGE_VERSION Exactly version.
#AC_PACKAGE_STRING, PACKAGE_STRING   Exactly ‘package version’.
#AC_PACKAGE_BUGREPORT, PACKAGE_BUGREPORT Exactly bug-report, if one was provided.
#AC_PACKAGE_URL, PACKAGE_URL Exactly url, if one was provided. If url was empty, but package begins with ‘GNU ’, then this defaults to ‘http://www.gnu.org/software/tarname/’, otherwise, no URL is assumed. 
    
AX_PROG_NASM([nasm_avail="no"])
#AX_PROG_NASM_OPT([-f obj], [NASM_OPTS])

PACKAGE_LDFLAGS="-melf_x86_64 -s"
PACKAGE_NASMFLAGS="-felf64"

AC_SUBST([PACKAGE_LDFLAGS])
AC_SUBST([PACKAGE_NASMFLAGS])

AM_INIT_AUTOMAKE(foreign)
#hello_SOURCES=hello.asm
AC_CONFIG_FILES(Makefile)
AC_OUTPUT
