TEMPLATE = app
CONFIG += console c++11
CONFIG -= app_bundle
CONFIG -= qt

SOURCES += \
        main.cpp

LIBS += -lXaw7
LIBS += -lXmu
LIBS += -lXt
LIBS += -lXrender
LIBS += -lX11
LIBS += -lXft
LIBS += -lxkbfile
