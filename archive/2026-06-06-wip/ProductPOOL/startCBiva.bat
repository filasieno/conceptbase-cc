@echo off
rem *** startCBiva.bat
rem *** ----------------------------------------------------------------------
rem *** This script allows to start the ConceptBase user interface without further
rem *** customization of ConceptBase configuration files.
rem *** See doc\TechInfo\InstallationGuide.txt for more details.
rem *** Can be started by double-click in the file explorer
rem *** It is assumed that the program java.exe is in the call path of Windows.
rem *** Due to some incompatibilities with the newest Java JRE (Java 6 after build 12),
rem *** we check for the existence of some older Java JRE and of a local Java that
rem *** may be shipped with the ConceptBase installation files. 
rem *** Otherwise, pre-pend the absolute call path of java.exe (default case).
rem *** 25-Aug-2004 (12-Jan-2010), M. Jeusfeld

SETLOCAL

set CB_HOME=%cd%
cd bin
if exist "%programfiles%\Java\jre1.6.0_10\bin\java.exe" goto :java6_10
if exist "%programfiles%\Java\jre1.6.0_07\bin\java.exe" goto :java6_07
if exist "%programfiles%\Java\jre1.5.0_18\bin\java.exe" goto :java5_18
if exist "%programfiles%\Java\jre1.5.0_21\bin\java.exe" goto :java5_21
if exist "%programfiles%\Java\jre1.5.0_22\bin\java.exe" goto :java5_22
if exist "..\jre1.6.0_07\bin\javaw.exe" goto :java_local


rem *** default java found via search path; might be incompatible
start /b java -DCB_HOME="%CB_HOME%" -jar "%CB_HOME%"\lib\classes\cb.jar
goto :alldone

rem *** local java found
:java_local
start /b ..\jre1.6.0_07\bin\javaw -DCB_HOME="%CB_HOME%" -jar "%CB_HOME%"\lib\classes\cb.jar
goto :alldone

rem *** java5_18 found
:java5_18
"%programfiles%\Java\jre1.5.0_18\bin\java.exe" -DCB_HOME="%CB_HOME%" -jar "%CB_HOME%"\lib\classes\cb.jar
goto :alldone

rem *** java5_21 found
:java5_21
"%programfiles%\Java\jre1.5.0_21\bin\java.exe" -DCB_HOME="%CB_HOME%" -jar "%CB_HOME%"\lib\classes\cb.jar
goto :alldone

rem *** java5_22 found
:java5_22
"%programfiles%\Java\jre1.5.0_22\bin\java.exe" -DCB_HOME="%CB_HOME%" -jar "%CB_HOME%"\lib\classes\cb.jar
goto :alldone

rem *** java6_07 found
:java6_07
"%programfiles%\Java\jre1.6.0_07\bin\java.exe" -DCB_HOME="%CB_HOME%" -jar "%CB_HOME%"\lib\classes\cb.jar
goto :alldone

rem *** java6_10 found
:java6_10
"%programfiles%\Java\jre1.6.0_10\bin\java.exe" -DCB_HOME="%CB_HOME%" -jar "%CB_HOME%"\lib\classes\cb.jar
goto :alldone


:alldone


