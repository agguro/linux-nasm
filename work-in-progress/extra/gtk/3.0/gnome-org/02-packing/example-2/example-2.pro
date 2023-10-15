TEMPLATE = app

SOURCES += main.c


# GTK+ library
unix: CONFIG	+= link_pkgconfig
unix: PKGCONFIG += gtk+-3.0
