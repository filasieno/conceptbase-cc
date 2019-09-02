@echo off

SETLOCAL

if not defined CB_HOME set CB_HOME=C:\conceptbase


if exist "%programfiles%\Java" goto :java_default
if exist "%CB_HOME%\windows\jre1.6.0_07\bin\javaw.exe" goto :java_local


rem *** default java found via search path
:java_default
java -DCB_HOME="%CB_HOME%" -classpath "%CB_HOME%\lib\classes\cb.jar" i5.cb.CBShell %*
goto :alldone

rem *** local java found
:java_local
%CB_HOME%\windows\jre1.6.0_07\bin\java.exe -DCB_HOME="%CB_HOME%" -classpath "%CB_HOME%\lib\classes\cb.jar" i5.cb.CBShell %*
goto :alldone


:alldone
