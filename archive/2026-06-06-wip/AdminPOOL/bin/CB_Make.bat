@echo off

SETLOCAL

set CB_VARIANT=windows
set CB_ADMIN=n:\CB_NewStruct\CB_Admin

%CB_ADMIN%\windows\make -re -f Makefile CB_MAKE=1 %*

