@echo off
setlocal
REM =============================================================================
REM UdderlyUpToDate Build 42 - Windows auto-restart wrapper
REM =============================================================================
REM The mod can only QUIT the Project Zomboid process. It cannot start it again.
REM Run this script instead of StartServer64.bat so the server comes back up
REM after UdderlyUpToDate (or a crash) exits the process.
REM
REM 1. Copy this file next to StartServer64.bat (Dedicated Server folder)
REM 2. Edit SERVER_BAT below if your start script has a different name
REM 3. Start the server with THIS file, not StartServer64.bat directly
REM =============================================================================

set "SERVER_BAT=StartServer64.bat"
set "RESTART_DELAY_SECONDS=10"

if not exist "%~dp0%SERVER_BAT%" (
	echo ERROR: Could not find "%~dp0%SERVER_BAT%"
	echo Place this script in the same folder as your dedicated server start bat.
	pause
	exit /b 1
)

:loop
echo.
echo [%date% %time%] Starting Project Zomboid server via %SERVER_BAT% ...
call "%~dp0%SERVER_BAT%"
echo.
echo [%date% %time%] Server process exited with code %ERRORLEVEL%.
echo Restarting in %RESTART_DELAY_SECONDS% seconds... (Ctrl+C to stop)
timeout /t %RESTART_DELAY_SECONDS% /nobreak >nul
goto loop
