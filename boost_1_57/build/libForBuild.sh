#!/bin/bash


checkCompilSuccess() {
   if [ -e "$1" ]; then
      echo " Ok."
   else
      echo "!BUILD FAILED : compil error, file \"$1\" doesn't exist."
      exit 99
   fi
}


#efface la liste $2 des sous rep ou fichiers contenus dans $1
removeFilesOrDirs() {
   MAINDIR=$1
   SUBDIRS=$2
   for  SUBDIR in ${SUBDIRS}
   do
      # echo "cleaning ${MAINDIR}/${SUBDIR}"
      if [ -e "${MAINDIR}/${SUBDIR}" ]; then
         rm -r ${MAINDIR}/${SUBDIR}
      fi
   done
}


# copie les liste de fichiers $1 du repertoire source $2 vers le repertoire destination $3
copyFilesFromSrcToDest() {
   FILES=$1
   SRCDIR=$2
   DESTDIR=$3
   
   for FILE in ${FILES}
   do
      cp ${SRCDIR}${FILE} ${DESTDIR}
      checkCompilSuccess  ${DESTDIR}${FILE}
   done
}


# cree un repertoire
# param : chemin du repertoire a creer
function createDir() {
   DIRPATH=$1
   if [ -z "$DIRPATH" ]
   then
     echo "!ERROR: Can't create directory with empty path."
     exit 99
   fi
   if [ ! -d $DIRPATH ]
   then
      mkdir $DIRPATH
      RET=$?
      if [ $RET -ne 0 ]
      then
         echo "!ERROR : Error during the creation of the directory $DIRPATH."
         exit $RET
      fi
   fi
}


# cree un repertoire. S'il existe deja, il est detruit et recree.
# param : chemin du repertoire a creer
function truncateDir() {
   DIRPATH=$1
   if [ -z "$DIRPATH" ]
   then
     echo "!ERROR: Can't create directory with empty path."
     exit 99
   fi
   if [ -d $DIRPATH ]
   then
      rm -rf $DIRPATH
      RET=$?
      if [ $RET -ne 0 ]
      then
         echo "!ERROR : Error during the erasing of the directory $DIRPATH."
         exit $RET
      fi
   fi
   createDir $DIRPATH
}


# copie un ensemble de fichiers/repertoires dans un repertoire, cree le repertoire s'il n'existe pas
# param 1 : chemin du repertoire ou copier les fichiers
# param 2 : 1er fichier/repertoire a copier
# param 3 : 2eme fichier/repertoire a copier
# ...
# param n : n-1eme fichier/repertoire a copier
function copyFiles() {
   DIRPATH=`getAbsolutPath $1`
   createDir $DIRPATH
   shift
   for PARAM in $*
   do
      FILE=`getAbsolutPath $1`
      if [ -e "$FILE" ]
      then
         cp -rp $FILE $DIRPATH
         RET=$?
         if [ $RET -ne 0 ]
         then
            echo "!ERROR : Error during copy of $FILE to directory $DIRPATH."
            exit $RET
         fi
      else
         echo "!ERROR : Can't copy $FILE doesn't exist."
         exit 99
      fi
   done
}


# extrait le contenu d'un tar dans le repertoire courant
# param 1 : chemin du tar a extraire
function extractTar() {
   TARFILEPATH=`getAbsolutPath $1`
   if [ -z "$TARFILEPATH" ]
   then
     echo "!ERROR: Can't extract tar with empty file path."
     exit 99
   fi
   case $TARFILEPATH in
      *tar) OPTION=xf ;;
      *tgz | *tar.gz) OPTION=xzf ;;
      *tar.bz2) OPTION=xjf ;;
      *tar.xz) OPTION=xJf ;;
      *) echo "!ERROR : Unknown tar format for $TARFILEPATH.";
         exit 99 ;;
   esac
   if [ -f "$TARFILEPATH" ]
   then
      tar $OPTION $TARFILEPATH
      RET=$?
      if [ $RET -ne 0 ]
      then
         echo "!ERROR : Error during the extraction of the tar $TARFILEPATH."
         exit $RET
      fi
   else
      echo "!ERROR : Can't extract tar $TARFILEPATH doesn't exist."
      exit 99
   fi
}


# cree un tar
# param 1 : chemin du tar a creer
# param 2 : liste des fichiers a mettre dans le tar
function createTar() {
   TARFILEPATH=`getAbsolutPath $1`
   FILELIST=$2
   
   if [ -z "$TARFILEPATH" ]
   then
     echo "!ERROR: Can't create tar with empty file path."
     exit 99
   fi
   
   if [ -z "$FILELIST" ]
   then
     echo "!ERROR: Can't create tar $TARFILEPATH with empty file list."
     exit 99
   fi
   
   case $TARFILEPATH in
      *tar) OPTION=cf ;;
      *tgz | *tar.gz) OPTION=czf ;;
      *tar.bz2) OPTION=cjf ;;
      *tar.xz) OPTION=cJf ;;
      *) echo "!ERROR : Unknown tar format for $TARFILEPATH.";
         exit 99 ;;
   esac

   createDir `dirname $TARFILEPATH`

   tar $OPTION $TARFILEPATH $FILELIST
   RET=$?

   if [ $RET -ne 0 ]
   then
      echo "!ERROR : Error during the creation of the file $TARFILEPATH."
      exit $RET
   else
      echo "Creation of the file $TARFILEPATH done."
   fi
}


# retourne le chemin absolu vers l'element fourni en parametre
function getAbsolutPath() {
   echo `readlink -m "$1"`
}


# rapatriement depuis svn d'un element
# param 1 : url du depot svn
# param 2 : version svn a rapatrier (trunk, tags/..., ...)
# param 3 : chemin du repertoire de destination du rapatriement
function exportSvn() {
   SVNURL=$1
   TAG=$2
   DESTDIR=`getAbsolutPath $3`
   SVNUSERNAME=commonengine
   SVNPASSWORD=de45hn68
   
   if [ -z "$SVNURL" ]
   then
      echo "!BUILD FAILED : compil error, can't export with empty svn url."
      exit 99
   fi
   if [ -z "$DESTDIR" ]
   then
      echo "!BUILD FAILED : compil error, can't export with empty destination dir path."
      exit 99
   fi
   NAME=`basename $DESTDIR`
   if [ -z "$TAG" ]
   then
      echo "!BUILD FAILED : compil error, can't export $NAME with empty tag."
      exit 99
   fi
   svn --no-auth-cache --force --username ${SVNUSERNAME} --password ${SVNPASSWORD} export ${SVNURL}/${TAG}/$NAME $DESTDIR
   if [ -e "$DEPENDENCYDIR/build/build.sh" ]; then
      echo "--- Ok."
   else
      echo "--- BUILD FAILED : svn error on CppExternalLib/${TAG}/$NAME"
      exit 99
   fi
}


# rapatriement depuis svn d'une dependance externe
# param : chemin du repertoire de destination du rapatriement
function exportExternalDependency() {
   exportSvn http://tonga.travelcom.michelin-travel.com/svn/CppExternalLib trunk $1
}


# compile une dependance dans CppExternalLib
# param 1 : chemin de la dependance a compiler
# param 2 : parametres pour le build de la dependance
function buildExternalDependency() {
   DEPENDENCYDIR=`getAbsolutPath $1`
   if [ -z "$DEPENDENCYDIR" ]
   then
      echo "!BUILD FAILED : compil error, can't build empty dependency."
      exit 99
   fi
   BUILDPARAM=$2
   if [ ! -d $DEPENDENCYDIR/include ]
   then
      if [ ! -e $DEPENDENCYDIR/build/build.sh ]
      then
         exportExternalDependency $DEPENDENCYDIR
      fi
      $DEPENDENCYDIR/build/build.sh $BUILDPARAM
      RET=$?
      if [ $RET -ne 0 ]
      then
         echo "!BUILD FAILED : compil error, can't build dependency $DEPENDENCYDIR."
         exit 99
      fi
   fi
}


# retourne le nom du fichier contenant la version des dependances
function getDependenciesVersionFileName() {
   echo "dependenciesVersion.txt"
}


# generation du fichier contenant la version des dependances de la librairie
# il sert pour determiner si une recompilation est necessaire en cas de changement de
# version des dependance par rapport a la version precompilee
# param 1 : chemin du repertoire ou creer le fichier
# param 2 : 1ere dependance (chemin de la racine de la librairie 1)
# param 3 : 2eme dependance (chemin de la racine de la librairie 2)
# ...
# param n : n-1eme dependance (chemin de la racine de la librairie n-1)
function generateDependenciesVersionFile() {
   DIRECTORYPATH=`getAbsolutPath $1`
   createDir $DIRECTORYPATH
   shift
   FILEPATH=$DIRECTORYPATH/`getDependenciesVersionFileName`
   > $FILEPATH
   if [ ! -f "$FILEPATH" ]
   then
      echo "!BUILD FAILED : compil error, can't create dependencies version file ($FILEPATH)."
      exit 99
   else
      if [ -s "$FILEPATH" ]
      then
         echo "!BUILD FAILED : compil error, can't erase dependencies version file content ($FILEPATH)."
         exit 99
      fi
   fi
   for DEPENDENCY in $*
   do
      echo `basename $DEPENDENCY` >> $FILEPATH
   done
}


# retourne l'identifiant prebuild
# param : chemin du repertoire racine de la librairie
function getPrebuiltId() {
   PREBUILTID="$(uname -a | awk '{printf $3}')"
   if [ -s "$1" ]
   then
      FILEPATH=$1/`getDependenciesVersionFileName`
      if [ -f "$FILEPATH" ]
      then
         SUM="$(md5sum $FILEPATH | awk '{printf $1}')"
         PREBUILTID="${PREBUILTID}_$SUM"
      fi
   fi
   echo "$PREBUILTID"
}


# retourne le repertoire contenant la version precompilee (correspondant a la version du noyau et des dependances eventuelles) si elle existe ou une chaine vide sinon
# param : chemin du repertoire racine de la librairie
function getPrebuiltDirectory() {
   if [ -z "$1" ]                           # Is parameter #1 zero length?
   then
     echo "ERROR: getPrebuiltDirectory(var directory) : missing parameter directory." >&2
     echo ""
   else
     DIRECTORY=$1
   fi
   STAMPCURRTARGET=`getPrebuiltId $DIRECTORY`
   if (test -d $DIRECTORY/$STAMPCURRTARGET)
   then
      DEPENDENCIESVERSIONFILENAME=`getDependenciesVersionFileName`
      if [ -f $DIRECTORY/$DEPENDENCIESVERSIONFILENAME ]
      then
         if [ -f $DIRECTORY/$STAMPCURRTARGET/$DEPENDENCIESVERSIONFILENAME ]
         then
            RESDIFF=`diff $DIRECTORY/$STAMPCURRTARGET/$DEPENDENCIESVERSIONFILENAME $DIRECTORY/$DEPENDENCIESVERSIONFILENAME`
            RET=$?
            if [ $RET -ne 0 ]
            then
               echo "Dependencies version mismatch :" >&2
               echo "$RESDIFF" >&2
               echo ""
            else
               echo $DIRECTORY/$STAMPCURRTARGET
            fi
         else
            echo "ERROR: Dependencies version file \"$DIRECTORY/$STAMPCURRTARGET/$DEPENDENCIESVERSIONFILENAME\" doesn't exist." >&2
            echo ""
         fi
      else
         echo $DIRECTORY/$STAMPCURRTARGET
      fi
   else
      echo ""
   fi
}


# generation d'un fichier a partir d'un autre en remplacant du texte et en copiant les permissions
# param 1 : chemin du fichier source
# param 2 : chemin du fichier destination
# parma 3 : remplacement a effectuer
function generateFileWithTextReplaceAndPermissionCopy() {
   SOURCEFILEPATH=`getAbsolutPath $1`
   if [ -z "$SOURCEFILEPATH" ]
   then
      echo "!BUILD FAILED : compil error, can't generate file with empty source file path."
      exit 99
   fi
   DESTFILEPATH=`getAbsolutPath $2`
   if [ -z "$DESTFILEPATH" ]
   then
      echo "!BUILD FAILED : compil error, can't generate file with empty dest file path."
      exit 99
   fi
   SEDREPLACE="$3"
   if [ -z "$SEDREPLACE" ]
   then
      echo "!BUILD FAILED : compil error, can't generate file with empty replace string."
      exit 99
   fi
   if [ -f "$SOURCEFILEPATH" ]
   then
      SOURCFILEPERMISSION=`stat -c %a "$SOURCEFILEPATH"`
      if [ -z "$SOURCFILEPERMISSION" ]
      then
         echo "!BUILD FAILED : compil error, can't find permission for file $SOURCEFILEPATH."
         exit 99
      fi
      cat $SOURCEFILEPATH | sed $SEDREPLACE > $DESTFILEPATH
      RET=$?
      if [ $RET -ne 0 ]
      then
         echo "!BUILD FAILED : compil error, can't generate file $DESTFILEPATH."
         exit 99
      fi
      chmod $SOURCFILEPERMISSION $DESTFILEPATH
      if [ $RET -ne 0 ]
      then
         echo "!BUILD FAILED : compil error, can't change permission for file $DESTFILEPATH."
         exit 99
      fi
   else
      echo "!BUILD FAILED : compil error, can't generate file $DESTFILEPATH because source file $SOURCEFILEPATH doesn't exist."
      exit 99
   fi
}


# generation du fichier template pour la version prebuilt
# param 1 : chemin du fichier source
# param 2 : 1er pattern a remplacer dans le fichier source (chemin de la racine de la librairie 1)
# param 3 : 2eme pattern a remplacer dans le fichier source (chemin de la racine de la librairie 2)
# ...
# param n : n-1eme pattern a remplacer dans le fichier source (chemin de la racine de la librairie n-1)
function generateTemplateFile() {
   FILEPATH=`getAbsolutPath $1`
   if [ -z "$FILEPATH" ]
   then
      echo "!BUILD FAILED : compil error, can't generate template with empty file path."
      exit 99
   fi
   shift
   SEDREPLACE=""
   LIBNUMBER="1"
   for PATTERN in $*
   do
      if [ -n "$PATTERN" ]
      then
         SEDREPLACE="$SEDREPLACE -e s,$PATTERN,\&library${LIBNUMBER}RootDir;,g"
         LIBNUMBER=`expr $LIBNUMBER + 1`
      fi
   done
   if [ -z "$SEDREPLACE" ]
   then
      echo "!BUILD FAILED : compil error, can't generate template with empty pattern."
      exit 99
   fi
   if [ -f "$FILEPATH" ]
   then
      TEMPLATEFILEPATH=$FILEPATH.template
      generateFileWithTextReplaceAndPermissionCopy $FILEPATH $TEMPLATEFILEPATH "$SEDREPLACE"
      RET=$?
      if [ $RET -ne 0 ]
      then
         echo "!BUILD FAILED : compil error, can't generate template file $TEMPLATEFILEPATH."
         exit 99
      fi
   else
      echo "!BUILD FAILED : compil error, can't generate template because file $FILEPATH doesn't exist."
      exit 99
   fi
}


# generation du fichier a partir du template avec les bonnes valeurs de chemin
# param 1 : chemin du fichier template
# param 2 : chemin de la racine de la librairie 1
# param 3 : chemin de la racine de la librairie 2
# ...
# param n : chemin de la racine de la librairie n-1
function generateFileFromTemplateFile() {
   FILEPATH=`getAbsolutPath $1`
   if [ -z "$FILEPATH" ]
   then
      echo "!BUILD FAILED : compil error, can't generate file with empty file path."
      exit 99
   fi
   shift
   SEDREPLACE=""
   LIBNUMBER="1"
   for VALUE in $*
   do
      if [ -n "$VALUE" ]
      then
         SEDREPLACE="$SEDREPLACE -e s,&library${LIBNUMBER}RootDir;,$VALUE,g"
         LIBNUMBER=`expr $LIBNUMBER + 1`
      fi
   done
   VALUE=$2
   if [ -z "$SEDREPLACE" ]
   then
      echo "!BUILD FAILED : compil error, can't generate file with empty value."
      exit 99
   fi
   TEMPLATEFILEPATH=$FILEPATH.template
   if [ -f "$TEMPLATEFILEPATH" ]
   then
      generateFileWithTextReplaceAndPermissionCopy $TEMPLATEFILEPATH $FILEPATH "$SEDREPLACE"
      RET=$?
      if [ $RET -ne 0 ]
      then
         echo "!BUILD FAILED : compil error, can't generate file $FILEPATH."
         exit 99
      fi
   else
      echo "!BUILD FAILED : compil error, can't generate file because template file $TEMPLATEFILEPATH doesn't exist."
      exit 99
   fi
}
