
@echo off

set CYGWIN=c:\cygwin
set SH=%CYGWIN%\bin\bash.exe

"%SH%" -c "/usr/bin/ansible-playbook %*"

