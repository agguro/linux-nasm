# Disable Qt core and Qt Graphical user interface (don't use Qt)
QT	    -= core
QT	    -= gui

# Name of the target (executable file)
TARGET	    = molecule

# This is a console application
CONFIG	    += console
CONFIG	    -= app_bundle

# This is an application
TEMPLATE    = app

# Sources files
SOURCES	    += \
#    createmenu.c \
    filesel.c \
    frontend.c \
    matrix3d.c \
    misc.c \
    molecule.c
    frontend.c

# GTK+ library
unix: CONFIG	+= link_pkgconfig
unix: PKGCONFIG += gtk+-2.0

HEADERS += \
    atom.h \
    matrix3d.h

DISTFILES += \
    Hydroxyp.pdb \
    buckeyball.pdb \
    capsaicin.pdb \
    molecule.pdb \
    organic.pdb \
    propane.pdb \
    sucrose.pdb \
    testosterone.pdb \
    vanillin.pdb \
    vitaminc.pdb
