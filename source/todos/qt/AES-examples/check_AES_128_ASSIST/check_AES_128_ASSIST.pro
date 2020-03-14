TEMPLATE = app
CONFIG += console
CONFIG -= app_bundle
CONFIG -= qt

QMAKE_CFLAGS += -maes -msse2 -msse
QMAKE_CFLAGS_DEBUG += -maes -msse2 -msse

SOURCES += \
        main.c
