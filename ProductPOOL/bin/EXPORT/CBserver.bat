@echo off

SETLOCAL

rem *** CB_HOME is the Directory where the ConceptBase Kernel System is installed
if not defined CB_HOME set CB_HOME=n:\CB_NewStruct\CB_Product

set CB_VARIANT=windows
set PROLOG_VARIANT=SWI
set CBS_DIR=%CB_HOME%\%CB_VARIANT%\lib\
set CBL_DIR=%CB_HOME%\lib\system

if "%1%"=="-h" goto help
if "%1%"=="" goto help
"%CB_HOME%\%CB_VARIANT%\bin\CBserver.exe" %*
goto ende

:help
echo "See ConceptBase User Manual for command line parameters or type CBserver -help"
echo " "

:ende


