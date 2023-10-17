TEMPLATE = app
CONFIG += console
CONFIG -= app_bundle
CONFIG -= qt

SOURCES += \
        main.c

# GTK4 library
unix: CONFIG	+= link_pkgconfig --cflags gtk4
unix: PKGCONFIG += gtk4

QMAKE_LFLAGS += -no-pie
