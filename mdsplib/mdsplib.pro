#TEMPLATE = app
TARGET = libmdsp
TEMPLATE = lib
CONFIG += staticlib
CONFIG -= app_bundle
CONFIG -= qt

DESTDIR = ../../lib/

SOURCES += \
    src/stspack3.c \
    src/stspack2.c \
    src/prtdmetr.c \
    src/fracpart.c \
    src/drvmetar.c \
    src/dcdmtrmk.c \
    src/dcdmetar.c \
    src/charcmp.c \
    src/antoi.c

HEADERS += \
    include/metar.h \
    src/metar_structs.h \
    src/local.h

