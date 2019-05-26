@echo off
rem *** startCBserver.bat
rem *** ----------------------------------------------------------------------
rem *** Script to start the ConceptBase server without having to set 
rem *** CB_HOME in advance. 
rem *** See doc\TechInfo\InstallationGuide.txt for more details.
rem *** Other than the standard script bin\CBserver.bat, this script also
rem *** works without installing ConceptBase on a computer system. 

SETLOCAL

rem *** CB_HOME is the Directory where the ConceptBase Kernel System is installed
set CB_HOME=.

set CB_VARIANT=windows
set PROLOG_VARIANT=SWI
set CBS_DIR=%CB_HOME%\%CB_VARIANT%\lib\
set CBL_DIR=%CB_HOME%\lib\system

if "%1%"=="-h" goto help
%CB_HOME%\%CB_VARIANT%\bin\CBserver.exe %* 
goto ende

:help
echo "Usage: CBserver <params>"
echo " "
echo "<params>:"
echo "-p <portnr>     : set portnumber for Client-Connections"
echo "                  <portnr> must be between 2000 and 65535"
echo "-d <db>         : set database to be loaded"
echo "-t <tracemode>  : set tracemode"
echo "                  <tracemode> is one of 'no','low','high','veryhigh' "
echo "-u <updatemode> : controls update persistency"
echo "                  <updatemode> is either 'persistent' or 'nonpersistent'"
echo "-c <cachemode>   : turn on the query cache to allow recursive query evaluation"
echo "                  <cachemode> is one of 'off', 'transient', 'keep' (=default)"
echo "-o <optmode>    : controls the optimizer for rangeform formulas"
echo "                  <optmode> is one of '0' (none), '1' (structural),"
echo "                 '2' (order) or '3' (struct.+order) "
echo "-r <secs>       : automatically restart the server after crash"
echo "                  <secs> specifies how many seconds to wait before restart"
echo "-gt x11         : use old initial database with graphical types for X11 graphbrowser"
echo "-s <seclevel>   : sets the security level of ConceptBase (0=disabled (default), 1=enabled)"
echo "-e <maxerr>     : sets the maximum number of error messages to be displayed (default: -1)"
echo "-cc strict|off  : strict: define any attribute label in a query predicate, off: default"


:ende

