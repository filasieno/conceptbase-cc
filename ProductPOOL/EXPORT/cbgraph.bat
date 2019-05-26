@echo off


SETLOCAL

rem *** If you installed ConceptBase to a different directory, then adapt CB_HOME
rem *** Avoid directory names with blanks or other special characters!
if not defined CB_HOME set CB_HOME=c:\conceptbase

cd %CB_HOME%

if exist "%programfiles%\Java" goto :java_default

rem *** default java found via search path
:java_default
timeout /T 1 > nul
if "%1"=="" goto :useohome

start /b javaw -DCB_HOME="%CB_HOME%" -cp "%CB_HOME%\lib\classes\cb.jar" i5.cb.graph.cbeditor.CBEditor %*
goto :alldone

:useohome
start /b javaw -DCB_HOME="%CB_HOME%" -cp "%CB_HOME%\lib\classes\cb.jar" i5.cb.graph.cbeditor.CBEditor "%CB_HOME%\lib\ohome.gel"
goto :alldone


:alldone


