@echo off
echo Setting up environment for ConceptBase Development

echo n: = /home/cbase
echo p: = /home/prolog
net use n: \\hopper\cbase
net use p: \\hopper\prolog

echo Adding CB_HOME\bin and SWI\bin to PATH
set PATH=%PATH%;n:\bin;p:\SWI\windows\bin;n:\CB_NewStruct\CB_Admin\windows

echo Loading Environment for MS Visual C++
call n:\MSVC\VC98\bin\VCVARS32.bat

