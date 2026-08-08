@echo off
setlocal EnableExtensions
REM =============================================================================
REM UdderlyUpToDate Build 42 - Windows auto-restart wrapper
REM =============================================================================
REM The mod can only QUIT the Project Zomboid process. It cannot start it again.
REM
REM IMPORTANT: Stock StartServer64.bat ends with "PAUSE" ("Press any key...").
REM That keeps the window open after the server dies, so a naive restart loop
REM never notices the quit. This wrapper strips PAUSE lines and runs a copy, so
REM when the server process exits the loop can start it again automatically.
REM
REM 1. Copy this file next to StartServer64.bat (Dedicated Server folder)
REM 2. Edit SERVER_BAT below if your start script has a different name
REM 3. Start the server with THIS file, not StartServer64.bat directly
REM =============================================================================

set "SERVER_BAT=StartServer64.bat"
set "RESTART_DELAY_SECONDS=10"
set "NOPAUSE_BAT=%TEMP%\UdderlyUpToDate_StartServer_NoPause.bat"

if not exist "%~dp0%SERVER_BAT%" (
	echo ERROR: Could not find "%~dp0%SERVER_BAT%"
	echo Place this script in the same folder as your dedicated server start bat.
	pause
	exit /b 1
)

:loop
echo.
echo [%date% %time%] Building no-pause launcher from %SERVER_BAT% ...
REM Drop PAUSE / pause lines so "Press any key" cannot block the restart loop.
findstr /V /I /R /C:"^[ 	]*pause" "%~dp0%SERVER_BAT%" > "%NOPAUSE_BAT%"
if errorlevel 1 (
	echo ERROR: Failed to create "%NOPAUSE_BAT%"
	pause
	exit /b 1
)

echo [%date% %time%] Starting Project Zomboid server...
pushd "%~dp0"
call "%NOPAUSE_BAT%"
set "EXIT_CODE=%ERRORLEVEL%"
popd

echo.
echo [%date% %time%] Server process exited with code %EXIT_CODE%.
echo Restarting in %RESTART_DELAY_SECONDS% seconds... (Ctrl+C to stop the wrapper)
timeout /t %RESTART_DELAY_SECONDS% /nobreak >nul
goto loop
