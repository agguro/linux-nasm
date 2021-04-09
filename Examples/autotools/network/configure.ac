AC_PREREQ([2.69])
AC_INIT([linuxnasm-network],[1.0.0],[aggurobe@gmail.com],[agguro],[https://linuxnasm.be])

AX_PROG_NASM([nasm_avail="no"])

AM_INIT_AUTOMAKE()

AM_PATH_LIBGCRYPT([1.8.5],,AC_MSG_ERROR([libcrypt 1.8.5 or higher required.]))
AC_CHECK_LIB([ssl], [OPENSSL_init_ssl], [],[AC_MSG_FAILURE([can't find openssl ssl lib])])

AC_OUTPUT([Makefile \
sslsocket/Makefile
])
