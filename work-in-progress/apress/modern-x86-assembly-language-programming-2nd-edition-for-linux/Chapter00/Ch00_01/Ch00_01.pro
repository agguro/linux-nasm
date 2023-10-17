QT -= core
QT -= gui
CONFIG += console
CONFIG -= app_bundle
TEMPLATE = app
QMAKE_LFLAGS_RELEASE += -s -no-pie
QMAKE_LFLAGS_DEBUG += -no-pie
QMAKE_EXTRA_COMPILERS += nasm

NASMEXTRAFLAGS = -f elf64 -g -F dwarf -I/nasm/include
nasm.output = ${QMAKE_FILE_BASE}.o
nasm.commands = nasm $$NASMEXTRAFLAGS -o ${QMAKE_FILE_BASE}.o ${QMAKE_FILE_NAME}
nasm.input = NASM_SOURCES

TARGET = Ch00_01

SOURCES += $$NASM_SOURCES \
    main.cpp
HEADERS +=

NASM_SOURCES += \
    global.asm

DISTFILES += \
    README.md
