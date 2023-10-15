TEMPLATE = app
CONFIG += console
CONFIG -= app_bundle
CONFIG -= qt

SOURCES += \
    Clock.c \
    xclock.c

LIBS += -lXaw7
LIBS += -lXmu
LIBS += -lXt
LIBS += -lXrender
LIBS += -lX11
LIBS += -lXft
LIBS += -lxkbfile

QMAKE_CFLAGS += -no-pie

HEADERS += \
    Clock.h \
    ClockP.h \
    app-defaults/XClock-color

DISTFILES += \
    app-defaults/XClock \
    clmask.bit \
    clock.bit
