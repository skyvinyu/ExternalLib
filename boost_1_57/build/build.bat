@echo off

set curr_version=1_53
set curr_job=%CD%\%0 V%curr_version%
set curr_libs=
set ms_build_path=C:\Program Files (x86)\MSBuild\12.0\Bin\
rem --with-serialization --with-system --with-thread --with-chrono --with-timer --with-filesystem --with-regex

:unzip
IF "%do_unzip%" EQU "no" GOTO patch 
echo %curr_job% unzip 
IF NOT EXIST boost_%curr_version%_0.tar call "C:\Program Files\7-Zip\7z.exe" e -y boost_%curr_version%_0.tar.bz2
IF NOT EXIST boost-src call "C:\Program Files\7-Zip\7z.exe" x -y boost_%curr_version%_0.tar
IF NOT EXIST boost-src rename boost_%curr_version%_0 boost-src

:patch
IF "%do_patch%" EQU "no" GOTO build 
xcopy build\patch\transform_width.hpp boost-src\boost\archive\iterators\transform_width.hpp /y
xcopy build\patch\auto_link.hpp boost-src\boost\config\auto_link.hpp /y


:build
IF "%do_build%" EQU "no" GOTO install
echo %curr_job% build 
call "C:\Program Files (x86)\Microsoft Visual Studio 12.0\VC\vcvarsall.bat" x86_amd64
cd boost-src
call bootstrap.bat toolset=msvc --build-type=complete
call bjam.exe toolset=msvc %curr_libs% link=static threading=multi address-model=64 --libdir=..\..\..\_xlibs\bin_Debug_x64 --includedir=..\..\..\_xlibs\include -sZLIB_SOURCE="C:\Workspaces\CppExternalLib\zlib_1_2_7\zlib-src\zlib-1.2.7" debug install
call bjam.exe toolset=msvc %curr_libs% link=static threading=multi address-model=64 --libdir=..\..\..\_xlibs\bin_Release_x64 --includedir=..\..\..\_xlibs\include -sZLIB_SOURCE="C:\Workspaces\CppExternalLib\zlib_1_2_7\zlib-src\zlib-1.2.7" release install
cd ..

:install    
IF "%do_install%" EQU "no" GOTO check
echo %curr_job% install 
move ..\..\_xlibs\include\boost-%curr_version%\boost ..\..\_xlibs\include\boost
rmdir ..\..\_xlibs\include\boost-%curr_version%

:check
echo %curr_job% check 
IF NOT EXIST ..\..\_xlibs\include\boost goto end_error
IF EXIST ..\..\_xlibs\bin_Debug_x64\libboost_thread-vc-mt-gd-%curr_version%.lib goto rename_debug_libs
IF EXIST ..\..\_xlibs\bin_Release_x64\libboost_thread-vc-mt-%curr_version%.lib goto rename_release_libs
IF NOT EXIST ..\..\_xlibs\bin_Debug_x64\libboost_thread-vc120-mt-gd-%curr_version%.lib goto end_error
IF NOT EXIST ..\..\_xlibs\bin_Release_x64\libboost_thread-vc120-mt-%curr_version%.lib goto end_error
SET ERRORLEV=0
echo *** %curr_job% OK
goto end

rem rename libraries it boost failed to write '120' compiler version in their name
:rename_debug_libs
echo %curr_job% rename_debug_libs
pushd ..\..\_xlibs\bin_Debug_x64\
ren libboost_atomic-vc-mt-gd-1_53.lib libboost_atomic-vc120-mt-gd-1_53.lib
ren libboost_chrono-vc-mt-gd-1_53.lib libboost_chrono-vc120-mt-gd-1_53.lib
ren libboost_context-vc-mt-gd-1_53.lib libboost_context-vc120-mt-gd-1_53.lib
ren libboost_date_time-vc-mt-gd-1_53.lib libboost_date_time-vc120-mt-gd-1_53.lib
ren libboost_exception-vc-mt-gd-1_53.lib libboost_exception-vc120-mt-gd-1_53.lib
ren libboost_filesystem-vc-mt-gd-1_53.lib libboost_filesystem-vc120-mt-gd-1_53.lib
ren libboost_graph-vc-mt-gd-1_53.lib libboost_graph-vc120-mt-gd-1_53.lib
ren libboost_iostreams-vc-mt-gd-1_53.lib libboost_iostreams-vc120-mt-gd-1_53.lib
ren libboost_locale-vc-mt-gd-1_53.lib libboost_locale-vc120-mt-gd-1_53.lib
ren libboost_math_c99-vc-mt-gd-1_53.lib libboost_math_c99-vc120-mt-gd-1_53.lib
ren libboost_math_c99f-vc-mt-gd-1_53.lib libboost_math_c99f-vc120-mt-gd-1_53.lib
ren libboost_math_c99l-vc-mt-gd-1_53.lib libboost_math_c99l-vc120-mt-gd-1_53.lib
ren libboost_math_tr1-vc-mt-gd-1_53.lib libboost_math_tr1-vc120-mt-gd-1_53.lib
ren libboost_math_tr1f-vc-mt-gd-1_53.lib libboost_math_tr1f-vc120-mt-gd-1_53.lib
ren libboost_math_tr1l-vc-mt-gd-1_53.lib libboost_math_tr1l-vc120-mt-gd-1_53.lib
ren libboost_prg_exec_monitor-vc-mt-gd-1_53.lib libboost_prg_exec_monitor-vc120-mt-gd-1_53.lib
ren libboost_program_options-vc-mt-gd-1_53.lib libboost_program_options-vc120-mt-gd-1_53.lib
ren libboost_random-vc-mt-gd-1_53.lib libboost_random-vc120-mt-gd-1_53.lib
ren libboost_regex-vc-mt-gd-1_53.lib libboost_regex-vc120-mt-gd-1_53.lib
ren libboost_serialization-vc-mt-gd-1_53.lib libboost_serialization-vc120-mt-gd-1_53.lib
ren libboost_signals-vc-mt-gd-1_53.lib libboost_signals-vc120-mt-gd-1_53.lib
ren libboost_system-vc-mt-gd-1_53.lib libboost_system-vc120-mt-gd-1_53.lib
ren libboost_test_exec_monitor-vc-mt-gd-1_53.lib libboost_test_exec_monitor-vc120-mt-gd-1_53.lib
ren libboost_thread-vc-mt-gd-1_53.lib libboost_thread-vc120-mt-gd-1_53.lib
ren libboost_timer-vc-mt-gd-1_53.lib libboost_timer-vc120-mt-gd-1_53.lib
ren libboost_unit_test_framework-vc-mt-gd-1_53.lib libboost_unit_test_framework-vc120-mt-gd-1_53.lib
ren libboost_wave-vc-mt-gd-1_53.lib libboost_wave-vc120-mt-gd-1_53.lib
ren libboost_wserialization-vc-mt-gd-1_53.lib libboost_wserialization-vc120-mt-gd-1_53.lib
ren libboost_zlib-vc-mt-gd-1_53.lib libboost_zlib-vc120-mt-gd-1_53.lib
popd
goto check

rem rename libraries it boost failed to write '120' compiler version in their name
:rename_release_libs
echo %curr_job% rename_release_libs
pushd ..\..\_xlibs\bin_Release_x64\
ren libboost_atomic-vc-mt-1_53.lib libboost_atomic-vc120-mt-1_53.lib
ren libboost_chrono-vc-mt-1_53.lib libboost_chrono-vc120-mt-1_53.lib
ren libboost_context-vc-mt-1_53.lib libboost_context-vc120-mt-1_53.lib
ren libboost_date_time-vc-mt-1_53.lib libboost_date_time-vc120-mt-1_53.lib
ren libboost_exception-vc-mt-1_53.lib libboost_exception-vc120-mt-1_53.lib
ren libboost_filesystem-vc-mt-1_53.lib libboost_filesystem-vc120-mt-1_53.lib
ren libboost_graph-vc-mt-1_53.lib libboost_graph-vc120-mt-1_53.lib
ren libboost_iostreams-vc-mt-1_53.lib libboost_iostreams-vc120-mt-1_53.lib
ren libboost_locale-vc-mt-1_53.lib libboost_locale-vc120-mt-1_53.lib
ren libboost_math_c99-vc-mt-1_53.lib libboost_math_c99-vc120-mt-1_53.lib
ren libboost_math_c99f-vc-mt-1_53.lib libboost_math_c99f-vc120-mt-1_53.lib
ren libboost_math_c99l-vc-mt-1_53.lib libboost_math_c99l-vc120-mt-1_53.lib
ren libboost_math_tr1-vc-mt-1_53.lib libboost_math_tr1-vc120-mt-1_53.lib
ren libboost_math_tr1f-vc-mt-1_53.lib libboost_math_tr1f-vc120-mt-1_53.lib
ren libboost_math_tr1l-vc-mt-1_53.lib libboost_math_tr1l-vc120-mt-1_53.lib
ren libboost_prg_exec_monitor-vc-mt-1_53.lib libboost_prg_exec_monitor-vc120-mt-1_53.lib
ren libboost_program_options-vc-mt-1_53.lib libboost_program_options-vc120-mt-1_53.lib
ren libboost_random-vc-mt-1_53.lib libboost_random-vc120-mt-1_53.lib
ren libboost_regex-vc-mt-1_53.lib libboost_regex-vc120-mt-1_53.lib
ren libboost_serialization-vc-mt-1_53.lib libboost_serialization-vc120-mt-1_53.lib
ren libboost_signals-vc-mt-1_53.lib libboost_signals-vc120-mt-1_53.lib
ren libboost_system-vc-mt-1_53.lib libboost_system-vc120-mt-1_53.lib
ren libboost_test_exec_monitor-vc-mt-1_53.lib libboost_test_exec_monitor-vc120-mt-1_53.lib
ren libboost_thread-vc-mt-1_53.lib libboost_thread-vc120-mt-1_53.lib
ren libboost_timer-vc-mt-1_53.lib libboost_timer-vc120-mt-1_53.lib
ren libboost_unit_test_framework-vc-mt-1_53.lib libboost_unit_test_framework-vc120-mt-1_53.lib
ren libboost_wave-vc-mt-1_53.lib libboost_wave-vc120-mt-1_53.lib
ren libboost_wserialization-vc-mt-1_53.lib libboost_wserialization-vc120-mt-1_53.lib
ren libboost_zlib-vc-mt-1_53.lib libboost_zlib-vc120-mt-1_53.lib
popd
goto check

:end_error
echo *** %curr_job% FAIL
SET ERRORLEV=1

:end

