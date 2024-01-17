# Disable Qt core and Qt Graphical user interface (don't use Qt)
QT	    -= core
QT	    -= gui

# Name of the target (executable file)
TARGET	    = example10
QMAKE_LFLAGS = -no-pie
QMAKE_LFLAGS_DEBUG = -no-pie

# This is a console application
CONFIG	    += console
CONFIG	    -= app_bundle

# This is an application
TEMPLATE    = app

# Sources files
SOURCES	    += main.c \
    exampleapp.c \
    exampleappprefs.c \
    exampleappwin.c \
    resource.c

# GTK+ library
unix: CONFIG	+= link_pkgconfig
unix: PKGCONFIG += gtk+-3.0

HEADERS += \
    exampleapp.h \
    exampleappprefs.h \
    exampleappwin.h

DISTFILES += \
    gschemas.compiled \
    exampleapp.gresource.xml \
    gschemas.compiled \
    org.gtk.exampleapp.gschema.valid \
    org.gtk.exampleapp.gschema.xml \
    prefs.ui \
    window.ui \
    app-menu.ui
