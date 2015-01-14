@echo off

set curr_version=1_57
set curr_job=%CD%\%0 V%curr_version%
set curr_libs=
set ms_build_path=C:\Program Files (x86)\MSBuild\12.0\Bin\
rem --with-serialization --with-system --with-thread --with-chrono --with-timer --with-filesystem --with-regex

:unzip
IF "%do_unzip%" EQU "no" GOTO patch 
echo %curr_job% unzip 
IF NOT EXIST boost-src call "C:\Program Files\7-Zip\7z.exe" x -y boost_%curr_version%_0.zip
IF NOT EXIST boost-src rename boost_%curr_version%_0 boost-src

:build
IF "%do_build%" EQU "no" GOTO install
echo %curr_job% build 
cd boost-src
call bootstrap.bat
call b2
cd ..

:install    
IF "%do_install%" EQU "no" GOTO check
echo %curr_job% install 
move boost_%curr_version%_0\include\boost-%curr_version%\boost ..\..\_xlibs\include\boost
move boost_%curr_version%_0\stage\lib ..\..\_xlibs\lib

:check
echo %curr_job% check 
IF NOT EXIST ..\..\_xlibs\include\boost goto end_error
IF EXIST ..\..\_xlibs\lib\libboost_thread-vc-mt-gd-%curr_version%.lib goto rename_debug_libs
IF EXIST ..\..\_xlibs\lib\libboost_thread-vc-mt-%curr_version%.lib goto rename_release_libs
IF NOT EXIST ..\..\_xlibs\lib\libboost_thread-vc120-mt-gd-%curr_version%.lib goto end_error
IF NOT EXIST ..\..\_xlibs\lib\libboost_thread-vc120-mt-%curr_version%.lib goto end_error
SET ERRORLEV=0
echo *** %curr_job% OK
goto end

:end_error
echo *** %curr_job% FAIL
SET ERRORLEV=1

:end

