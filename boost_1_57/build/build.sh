#!/bin/sh

# ce script a pour but de compiler boost ou d'utiliser le tar.bz2 precompile

function printUsage() {
   echo "Usage: `basename $0` [<logFilePath>] [--pythondir=<pythonDirPath>]"
   echo "logFilePath : build log file path (default value : `getAbsolutPath $REPSCRIPT/build.log`)"
   echo "pythonDirPath : root directory path for python (default value : $PYTHON_DIR)"
}

REPSCRIPT=`dirname $0`

LIBFORBUILDFILEPATH=$REPSCRIPT/../../common/build/libForBuild.sh

if [ ! -f $LIBFORBUILDFILEPATH ]
then
   # pour compatibilite avec les applications taggues avant le changement de build, on utilise le fichier local
   echo "!BUILD WARNING : file \"$LIBFORBUILDFILEPATH\" doesn't exist. To suppress this warning, add CppExternalLib/common checkout in your buildFwk-<Application>.sh script."
   LIBFORBUILDFILEPATH=$REPSCRIPT/libForBuild.sh
fi

. $LIBFORBUILDFILEPATH

PYTHON_DIR=`getAbsolutPath $REPSCRIPT/../../python_2_6_7`

for ac_option
do
  ac_optarg=`expr "x$ac_option" : 'x[^=]*=\(.*\)'`

  case $ac_option in

  -pythondir=* | --pythondir=* )
    PYTHON_DIR=`getAbsolutPath $ac_optarg` ;;
  -h | -\?) printUsage ; exit 0 ;;
  -*) echo "Option invalide : $ac_option" ; printUsage ; exit 1 ;;
  *) TRACEFILE=`getAbsolutPath $ac_option` ;;

  esac
done

cd $REPSCRIPT

if [ -z "$TRACEFILE" ]
then
   TRACEFILE=`getAbsolutPath build.log`
fi

TOOLNAME="boost"
TOOLVERSION="1_53_0"
TOOLFULLNAME=${TOOLNAME}_${TOOLVERSION}
TOOLBUILDDIR=${TOOLNAME}_build
BOOSTLIBRARIES=chrono,timer,thread,python,regex,filesystem,program_options,system,serialization,iostreams

buildExternalDependency $PYTHON_DIR >>"$TRACEFILE" 2>&1

cd ..
SEARCHPREBUILT=`pwd`
generateDependenciesVersionFile $SEARCHPREBUILT $PYTHON_DIR
export NO_BZIP2=1

TOOLDIR=`pwd`

PREBUILTDIRECTORY=`getPrebuiltDirectory $SEARCHPREBUILT`
if [ -z "$PREBUILTDIRECTORY" ]; then
   echo "--> prebuilt library not found (change of kernel release or dependencies) = build ${TOOLFULLNAME}"
   truncateDir ${TOOLBUILDDIR}
   cd ${TOOLBUILDDIR}
   extractTar ../${TOOLFULLNAME}.tar.bz2
   cd ${TOOLFULLNAME}
   . ./bootstrap.sh --prefix="$TOOLDIR" --with-libraries=$BOOSTLIBRARIES --with-python-root=$PYTHON_DIR >>"$TRACEFILE" 2>&1
   ./bjam -j8 >>"$TRACEFILE" 2>&1
   ./bjam -j8 install >>"$TRACEFILE" 2>&1

   echo "end_boost_include=" > $TOOLDIR/make.depends
   echo "end_boost_libname=" >> $TOOLDIR/make.depends
   echo "end_boost_so=.`echo $TOOLVERSION | sed -e 's/_/./g'`" >> $TOOLDIR/make.depends
else
   echo "--> same kernel release and dependencies = prebuilt library ${TOOLFULLNAME}"
   extractTar $PREBUILTDIRECTORY/${TOOLFULLNAME}.tar.bz2
fi

for LIBTOCHECK in `echo $BOOSTLIBRARIES | sed -e 's/,/ /g'`
do
   INCLUDEFILE=`echo $LIBTOCHECK | sed -e 's:^system$:system/system_error:' -e 's:^serialization$:serialization/serialization:' -e 's:^iostreams$:iostreams/stream:'`
   checkCompilSuccess ${TOOLDIR}/include/boost/${INCLUDEFILE}.hpp
   checkCompilSuccess ${TOOLDIR}/lib/libboost_${LIBTOCHECK}.a
   checkCompilSuccess ${TOOLDIR}/lib/libboost_${LIBTOCHECK}.so
done
checkCompilSuccess ${TOOLDIR}/make.depends
