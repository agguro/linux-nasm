TEMPLATE = app
CONFIG += console
CONFIG -= app_bundle
CONFIG -= qt

SOURCES += \
        main.c

# GTK+ library
unix: CONFIG	+= link_pkgconfig
unix: PKGCONFIG += gtk+-2.0

HEADERS +=
