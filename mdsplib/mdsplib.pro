TEMPLATE = app
CONFIG += console
CONFIG -= app_bundle
CONFIG -= qt

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
    src/metar_structs.h \
    src/local.h \
    include/metar.h

