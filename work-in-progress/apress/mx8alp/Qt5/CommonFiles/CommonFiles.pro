TEMPLATE = app
CONFIG += console c++11
CONFIG -= app_bundle
CONFIG -= qt

SOURCES += \
    mat4x4.cpp \
    mmxval.cpp \
    xmmval.cpp \
    ymmval.cpp

QMAKE_EXTRA_COMPILERS += nasm
NASMEXTRAFLAGS = -f elf32 -g -F dwarf

OTHER_FILES += $$NASM_SOURCES
nasm.output = ${QMAKE_FILE_BASE}.o
nasm.commands = nasm $$NASMEXTRAFLAGS -o ${QMAKE_FILE_BASE}.o ${QMAKE_FILE_NAME}
nasm.input = NASM_SOURCES

NASM_SOURCES += 

HEADERS += \
    miscdefs.h \
    mat4x4.h \
    mmxval.h \
    xmmval.h \
    ymmval.h
