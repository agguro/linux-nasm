# paths to include files must be set relative to build directory
QT -= gui
CONFIG -= app_bundle qt
QMAKE_LFLAGS_RELEASE += -s

TEMPLATE = lib
CONFIG += staticlib

QMAKE_EXTRA_COMPILERS += nasm
NASMEXTRAFLAGS = -f elf64 -g -F dwarf

nasm.output = ${QMAKE_FILE_BASE}.o
nasm.commands = nasm $$NASMEXTRAFLAGS -o ${QMAKE_FILE_BASE}.o ${QMAKE_FILE_NAME}
nasm.input = NASM_SOURCES
OTHER_FILES += $$NASM_SOURCES

HEADERS += functions.inc

# Default rules for deployment.
unix {
    target.path = /usr/lib
}
!isEmpty(target.path): INSTALLS += target

NASM_SOURCES += \
../source/c/ftok.asm \
../source/c/pagesize.asm \
../source/datetime/leapyear.asm \
../source/datetime/daysinmonth.asm \
../source/datetime/quadrimester.asm \
../source/datetime/semester.asm \
../source/datetime/shiftedmonth.asm \
../source/datetime/trimester.asm \
../source/system/sleep.asm


