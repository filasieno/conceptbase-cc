@echo off


SETLOCAL


rem *** If you installed ConceptBase to a different directory, then adapt CB_HOME
rem *** Avoid directory names with blanks or other special characters!
if not defined CB_HOME set CB_HOME=c:\conceptbase

cd %CB_HOME%

if exist "%programfiles%\Java" goto :java_default


rem *** default java found via search path, wait 1 sec to let java start
:java_default
timeout /T 1 > nul
# start /b javaw -DCB_HOME="%CB_HOME%" -jar "%CB_HOME%"\lib\classes\cb.jar
start /b javaw -DCB_HOME="%CB_HOME%" -classpath "%CB_HOME%"\lib\classes\* i5.cb.workbench.CBIva
goto :alldone



:alldone




