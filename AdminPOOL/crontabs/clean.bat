call \\hopper\cbase\bin\CB_env.bat

n:

del n:\crontabs\log\cron.weekly.clean.windows.log
cd \CB_NewStruct\ProductPOOL
hostname > n:\crontabs\log\cron.weekly.clean.windows.log 2>&1
call CB_Make clean >> n:\crontabs\log\cron.weekly.clean.windows.log 2>&1

c:

net use n: /delete
net use p: /delete

