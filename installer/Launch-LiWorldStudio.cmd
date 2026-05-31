@echo off
setlocal
set "ROOT=%~dp0"
set "PROFILE=%~1"
if "%PROFILE%"=="" set "PROFILE=game"
set STUDIO_DEMO_PROFILE=%PROFILE%
set STUDIO_DEMO_FRAMES=3
if /I "%~2"=="present" set LIG_HOST_PRESENT=1
if /I "%~2"=="present" if exist "%ROOT%studio_shell_present_host.exe" set "STUDIO_SHELL_PRESENT_HOST_BIN=%ROOT%studio_shell_present_host.exe"
if /I "%~2"=="present" if exist "%ROOT%studio_shell_present_host" set "STUDIO_SHELL_PRESENT_HOST_BIN=%ROOT%studio_shell_present_host"
"%ROOT%li-studio-demo.exe"
exit /b %ERRORLEVEL%
