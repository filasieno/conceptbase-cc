call \\hopper\cbase\bin\CB_env.bat

SET SCRIPTDIR=n:\CB_NewStruct\CB_Admin\utils\CB_TestClient\scripts

SET CB_PORTNR=6387
n:

move /Y n:\crontabs\log\cron.weekly.test.windows.log n:\crontabs\old
cd \crontabs\servertest\windows

move /Y ..\log\*.windows ..\old

mkdir AnswerFormat
copy n:\CB_NewStruct\ProductPOOL\src\examples\AnswerFormat\*.lpi AnswerFormat

hostname > n:\crontabs\log\cron.weekly.test.windows.log 2>&1

call CBshell -l -f %SCRIPTDIR%\..\stopServer.cbs > n:\crontabs\log\cron.weekly.test.windows.log 2>&1

call CBshell -l -f %SCRIPTDIR%\AnswerFormat.cbs >> n:\crontabs\log\cron.weekly.test.windows.log 2>&1
move /Y stat.log ..\log\stat.AnswerFormat.windows
move /Y error.log ..\log\error.AnswerFormat.windows
del /q AnswerFormat
rmdir AnswerFormat

call CBshell -l -f %SCRIPTDIR%\BigFlights.cbs >> n:\crontabs\log\cron.weekly.test.windows.log 2>&1
move /Y stat.log ..\log\stat.BigFlights.windows
move /Y error.log ..\log\error.BigFlights.windows
del /q BigFlights
rmdir BigFlights

call CBshell -l -f %SCRIPTDIR%\BigFlights2.cbs >> n:\crontabs\log\cron.weekly.test.windows.log 2>&1
move /Y stat.log ..\log\stat.BigFlights2.windows
move /Y error.log ..\log\error.BigFlights2.windows
del /q BigFlights2
rmdir BigFlights2

mkdir BuiltinQueries
copy n:\CB_NewStruct\ProductPOOL\src\examples\BuiltinQueries\*.lpi BuiltinQueries

call CBshell -l -f %SCRIPTDIR%\BuiltinQueries.cbs >> n:\crontabs\log\cron.weekly.test.windows.log 2>&1
move /Y stat.log ..\log\stat.BuiltinQueries.windows
move /Y error.log ..\log\error.BuiltinQueries.windows
del /q BuiltinQueries
rmdir BuiltinQueries

call CBshell -l -f %SCRIPTDIR%\DWQ.cbs >> n:\crontabs\log\cron.weekly.test.windows.log 2>&1
move /Y stat.log ..\log\stat.DWQ.windows
move /Y error.log ..\log\error.DWQ.windows
del /q DWQ
rmdir DWQ

call CBshell -l -f %SCRIPTDIR%\Datalog.cbs >> n:\crontabs\log\cron.weekly.test.windows.log 2>&1
move /Y stat.log ..\log\stat.Datalog.windows
move /Y error.log ..\log\error.Datalog.windows
del /q Datalog
rmdir Datalog

mkdir ECArules
copy n:\CB_NewStruct\ProductPOOL\src\examples\ECArules\*.lpi ECArules

call CBshell -l -f %SCRIPTDIR%\ECArules.cbs >> n:\crontabs\log\cron.weekly.test.windows.log 2>&1
move /Y stat.log ..\log\stat.ECArules.windows
move /Y error.log ..\log\error.ECArules.windows
del /q ECArules
rmdir ECArules

call CBshell -l -f %SCRIPTDIR%\ER_Model.cbs >> n:\crontabs\log\cron.weekly.test.windows.log 2>&1
move /Y stat.log ..\log\stat.ER_Model.windows
move /Y error.log ..\log\error.ER_Model.windows
del /q ER_Model
rmdir ER_Model

call CBshell -l -f %SCRIPTDIR%\FLIGHT_100.cbs >> n:\crontabs\log\cron.weekly.test.windows.log 2>&1
move /Y stat.log ..\log\stat.FLIGHT_100.windows
move /Y error.log ..\log\error.FLIGHT_100.windows
del /q FLIGHT_100
rmdir FLIGHT_100

call CBshell -l -f %SCRIPTDIR%\MetaFormulas.cbs >> n:\crontabs\log\cron.weekly.test.windows.log 2>&1
move /Y stat.log ..\log\stat.MetaFormulas.windows
move /Y error.log ..\log\error.MetaFormulas.windows
del /q MetaFormulas
rmdir MetaFormulas

call CBshell -l -f %SCRIPTDIR%\Modules.cbs >> n:\crontabs\log\cron.weekly.test.windows.log 2>&1
move /Y stat.log ..\log\stat.Modules.windows
move /Y error.log ..\log\error.Modules.windows
del /q Modules
rmdir Modules

call CBshell -l -f %SCRIPTDIR%\QUERIES_FRAME.cbs >> n:\crontabs\log\cron.weekly.test.windows.log 2>&1
move /Y stat.log ..\log\stat.QUERIES_FRAME.windows
move /Y error.log ..\log\error.QUERIES_FRAME.windows
del /q QUERIES_FRAME
rmdir QUERIES_FRAME


call CBshell -l -f %SCRIPTDIR%\QUERIES_LABEL.cbs >> n:\crontabs\log\cron.weekly.test.windows.log 2>&1
move /Y stat.log ..\log\stat.QUERIES_LABEL.windows
move /Y error.log ..\log\error.QUERIES_LABEL.windows
del /q QUERIES_LABEL
rmdir QUERIES_LABEL


call CBshell -l -f %SCRIPTDIR%\RECURSION.cbs >> n:\crontabs\log\cron.weekly.test.windows.log 2>&1
move /Y stat.log ..\log\stat.RECURSION.windows
move /Y error.log ..\log\error.RECURSION.windows
del /q RECURSION
rmdir RECURSION


call CBshell -l -f %SCRIPTDIR%\RULES_CONSTRAINTS.cbs >> n:\crontabs\log\cron.weekly.test.windows.log 2>&1
move /Y stat.log ..\log\stat.RULES_CONSTRAINTS.windows
move /Y error.log ..\log\error.RULES_CONSTRAINTS.windows
del /q RULES_CONSTRAINTS
rmdir RULES_CONSTRAINTS


call CBshell -l -f %SCRIPTDIR%\SYSTEM.cbs >> n:\crontabs\log\cron.weekly.test.windows.log 2>&1
move /Y stat.log ..\log\stat.SYSTEM.windows
move /Y error.log ..\log\error.SYSTEM.windows
del /q SYSTEM
rmdir SYSTEM

call CBshell -l -f %SCRIPTDIR%\USU.cbs >> n:\crontabs\log\cron.weekly.test.windows.log 2>&1
move /Y stat.log ..\log\stat.USU.windows
move /Y error.log ..\log\error.USU.windows
del /q USU
rmdir USU

call CBshell -l -f %SCRIPTDIR%\Views.cbs >> n:\crontabs\log\cron.weekly.test.windows.log 2>&1
move /Y stat.log ..\log\stat.Views.windows
move /Y error.log ..\log\error.Views.windows
del /q Views
rmdir Views

call CBshell -l -f %SCRIPTDIR%\X-Petrinet-simu.cbs >> n:\crontabs\log\cron.weekly.test.windows.log 2>&1
move /Y stat.log ..\log\stat.X-Petrinet-simu.windows
move /Y error.log ..\log\error.X-Petrinet-simu.windows
del /q X-Petrinet-simu
rmdir X-Petrinet-simu

c:
net use n: /delete
net use p: /delete

