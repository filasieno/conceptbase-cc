@echo off

SETLOCAL

if not defined CB_HOME set CB_HOME=//hopper/cbase/CB_NewStruct/CB_Product
java -DCB_HOME="%CB_HOME%" -classpath "%CB_HOME%\lib\classes\cb.jar" i5.cb.CBShell %*


