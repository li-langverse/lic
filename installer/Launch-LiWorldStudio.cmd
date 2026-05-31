@echo off
setlocal
set "ROOT=%~dp0"
set "PROFILE=%~1"
set "HOST_PRESENT="
if /I "%~2"=="present" set "HOST_PRESENT=-HostPresent"
powershell -NoProfile -ExecutionPolicy Bypass -File "%ROOT%launch-li-world-studio.ps1" -Profile "%PROFILE%" %HOST_PRESENT%
exit /b %ERRORLEVEL%
