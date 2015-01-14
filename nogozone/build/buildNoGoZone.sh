#!/bin/bash
# This script download the NoGoZone source and compile it

BASEDIR=$HOME
EXEC_NAME="NoGoZone"
EXEC_VERSION="1.1"
EXEC_WHOLENAME=${EXEC_NAME}-${EXEC_VERSION}
DEFAULT_URL="http://iweb.dl.sourceforge.net/project/nogozone/NoGoZone/NoGoZone-1.1/${EXEC_WHOLENAME}.tar.gz"

#USAGE="usage: `basename $0` <installDir> [<url>]"
USAGE="usage: `basename $0` [<installDir>]"

# Todo: Add argument parsing for url -u http://host/... 
if (test $# -lt 1)
then
    echo "No installDir given in argument"
    echo $USAGE
    echo "Install at default directory"
else
    BASEDIR=$1
fi

echo "Install directory: $BASEDIR"

if [ -e "$BASEDIR" ]; then
    echo "Base directory exists: $BASEDIR"
else
    echo "Creat base directory: $BASEDIR"
    mkdir $BASEDIR
fi

# Todo: get patched source from github insteed of downloading source from official site
cd $BASEDIR
wget $DEFAULT_URL
tar xzvf ${EXEC_WHOLENAME}.tar.gz

export CHIPS_ROOT="$BASEDIR/$EXEC_WHOLENAME"
echo "Set build dir: $CHIPS_ROOT"

# Rebuild exec
cd $BASEDIR/$EXEC_WHOLENAME/${EXEC_NAME}_source

# Remove prebuild package
mkdir prebuild
mv bin lib obj prebuild
mkdir bin lib obj
cd src

make -j8



