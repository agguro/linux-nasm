# Disable Qt core and Qt Graphical user interface (don't use Qt)
QT	    -= core
QT	    -= gui

# Name of the target (executable file)
TARGET	    = combobox

# This is a console application
CONFIG	    += console
CONFIG	    -= app_bundle

# This is an application
TEMPLATE    = app

# Sources files
SOURCES	    += \
    combobox.c

# GTK+ library
unix: CONFIG	+= link_pkgconfig
unix: PKGCONFIG += gtk+-2.0
