CONFIG += console c++11
CONFIG -= app_bundle
CONFIG -= qt
TEMPLATE = app
QMAKE_LFLAGS += -no-pie
QMAKE_EXTRA_COMPILERS += nasm

NASMEXTRAFLAGS = -f elf64 -g -F dwarf
nasm.output = ${QMAKE_FILE_BASE}.o
nasm.commands = nasm $$NASMEXTRAFLAGS -o ${QMAKE_FILE_BASE}.o ${QMAKE_FILE_NAME}
nasm.input = NASM_SOURCES

TARGET = Driver

SOURCES += $$NASM_SOURCES \
    main.cpp

HEADERS +=

NASM_SOURCES += \
    asm/addarray.asm