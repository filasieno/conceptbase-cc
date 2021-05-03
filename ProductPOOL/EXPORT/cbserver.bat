@echo off

SETLOCAL

rem *** This Windows has a Linux sub-system
if exist c:\Windows\System32\bash.exe goto viabash

rem *** The variant CBserver.exe is legacy, it is no longer shipped with ConceptBase since V7.5
rem *** CB_HOME is the Directory where the ConceptBase Kernel System is installed
if not defined CB_HOME set CB_HOME=%cd%

set CB_VARIANT=windows
set PROLOG_VARIANT=SWI
set CBS_DIR=%CB_HOME%\%CB_VARIANT%\lib\
set CBL_DIR=%CB_HOME%\lib\system

if "%1%"=="-h" goto help
"%CB_HOME%\%CB_VARIANT%\bin\CBserver.exe" %*
goto ende

help
echo "See ConceptBase User Manual for command line parameters or type CBserver -help"
echo " "
goto ende


rem *** Start CBserver via the Linux sub-system of Windows 10
rem *** Only works if ConceptBase is installed with linux64 directory into c:\conceptbase
rem *** Note: The 64bit app bash can only be called from Java 64bit, not from Java32bit!
:viabash
if "%*"=="" goto slave
bash -c "/mnt/c/conceptbase/cbserver -t low -a %username% %*"
goto ende

:slave
rem *** No parameters given: start a slave CBserver
bash -c "/mnt/c/conceptbase/cbserver -t low -sm slave -a %username% %*"
goto ende


:ende


