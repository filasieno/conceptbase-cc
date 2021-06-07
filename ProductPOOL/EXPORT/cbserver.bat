@echo off

SETLOCAL

rem *** We can give some help
if "%1%"=="-h" goto help

rem *** Great! This Windows has a Linux sub-system WSL
if exist c:\Windows\System32\bash.exe goto viabash

rem *** Else: This Windows has no sub-system WSL

echo "ConceptBase server under Windows requires WSL or WSL2, see conceptbase.cc or user manual"
goto ende

:help
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


