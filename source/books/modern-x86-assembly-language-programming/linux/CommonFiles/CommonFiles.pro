TEMPLATE = app
CONFIG += console c++11
CONFIG -= app_bundle
CONFIG -= qt

SOURCES += \
        mat4x4.cpp \
        mmxval.cpp \
        xmmval.cpp \
        ymmval.cpp

HEADERS += \
    mat4x4.h \
    miscdefs.h \
    mmxval.h \
    xmmval.h \
    ymmval.h
