#!/bin/sh

REPSCRIPT=`dirname $0`

LIBFORBUILDFILEPATH=$REPSCRIPT/../../common/build/libForBuild.sh

if [ -f $LIBFORBUILDFILEPATH ]
then
   . $LIBFORBUILDFILEPATH
else
   echo "!ERROR : file \"$LIBFORBUILDFILEPATH\" doesn't exist. To correct this error, do CppExternalLib/common checkout."
   exit 1
fi

cd $REPSCRIPT/..
LIBDIR=`pwd`
PREBUILTID=`getPrebuiltId $LIBDIR`
copyFiles $PREBUILTID `getDependenciesVersionFileName`
createTar $PREBUILTID/boost_1_53_0.tar.bz2 "include lib make.depends"
