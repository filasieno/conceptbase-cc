@echo off

SETLOCAL

if not defined CB_HOME set CB_HOME=\\hopper\cbase\CB_NewStruct\CB_Product

if exist "%programfiles%\Java\jre1.6.0_07\bin\java.exe" goto :java6_07
if exist "%programfiles%\Java\jre1.5.0_18\bin\java.exe" goto :java5_18
if exist "%programfiles%\Java\jre1.5.0_21\bin\java.exe" goto :java5_21
if exist "%CB_HOME%\..\jre1.6.0_07\bin\java.exe" goto :java_local




rem *** default java found via search path
start /b java -DCB_HOME="%CB_HOME%" -jar "%CB_HOME%"\lib\classes\cb.jar
goto :alldone


rem *** local java found
:java_local
"%CB_HOME%\..\jre1.6.0_07\bin\java.exe" -DCB_HOME="%CB_HOME%" -jar "%CB_HOME%"\lib\classes\cb.jar
goto :alldone


rem *** java5_18 found
:java5_18
"%programfiles%\Java\jre1.5.0_18\bin\java.exe" -DCB_HOME="%CB_HOME%" -jar "%CB_HOME%"\lib\classes\cb.jar
goto :alldone


rem *** java5_21 found
:java5_21
"%programfiles%\Java\jre1.5.0_21\bin\java.exe" -DCB_HOME="%CB_HOME%" -jar "%CB_HOME%"\lib\classes\cb.jar
goto :alldone


rem *** java6_07 found
:java6_07
"%programfiles%\Java\jre1.6.0_07\bin\java.exe" -DCB_HOME="%CB_HOME%" -jar "%CB_HOME%"\lib\classes\cb.jar
goto :alldone

:alldone

