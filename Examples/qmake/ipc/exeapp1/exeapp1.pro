# paths to include files must be set relative to build directory
QT -= gui
CONFIG -= app_bundle
CONFIG -= qt
QMAKE_LFLAGS_RELEASE += -s -no-pie
QMAKE_LFLAGS_DEBUG += -no-pie
CONFIG += c++11 console
CONFIG -= app_bundle

QMAKE_EXTRA_COMPILERS += nasm
NASMEXTRAFLAGS = -f elf64 -g -F dwarf

nasm.output = ${QMAKE_FILE_BASE}.o
nasm.commands = nasm $$NASMEXTRAFLAGS -o ${QMAKE_FILE_BASE}.o ${QMAKE_FILE_NAME}
nasm.input = NASM_SOURCES
OTHER_FILES += $$NASM_SOURCES

NASM_SOURCES += exeapp1.asm

HEADERS += exeapp1.inc

copydata.commands = $(COPY_FILE) $$PWD/hello $$OUT_PWD
first.depends = $(first) copydata
export(first.depends)
export(copydata.commands)
QMAKE_EXTRA_TARGETS += first copydata

DISTFILES += \
    hello