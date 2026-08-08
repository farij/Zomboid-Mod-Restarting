@echo off
setlocal EnableExtensions
REM =============================================================================
REM UdderlyUpToDate Build 42 - Windows auto-restart wrapper
REM =============================================================================
REM The mod can only QUIT the Project Zomboid process. It cannot start it again.
REM
REM IMPORTANT: Stock StartServer64.bat ends with "PAUSE" ("Press any key...").
REM That keeps the window open after the server dies, so a naive restart loop
REM never notices the quit. This wrapper strips PAUSE lines and runs a copy in
REM the SAME folder as StartServer64.bat (not %%TEMP%%), so relative paths and
REM %%~dp0 inside the start script still resolve correctly.
REM
REM 1. Copy this file next to StartServer64.bat (Dedicated Server folder)
REM 2. Edit SERVER_BAT below if your start script has a different name
REM 3. Start the server with THIS file, not StartServer64.bat directly
REM =============================================================================

set "SERVER_DIR=%~dp0"
set "SERVER_BAT=StartServer64.bat"
set "RESTART_DELAY_SECONDS=10"
set "NOPAUSE_BAT=%SERVER_DIR%UdderlyUpToDate_StartServer_NoPause.bat"

if not exist "%SERVER_DIR%%SERVER_BAT%" (
	echo ERROR: Could not find "%SERVER_DIR%%SERVER_BAT%"
	echo Place this script in the same folder as your dedicated server start bat.
	pause
	exit /b 1
)

cd /d "%SERVER_DIR%"
if errorlevel 1 (
	echo ERROR: Could not change directory to "%SERVER_DIR%"
	pause
	exit /b 1
)

:loop
echo.
echo [%date% %time%] Building no-pause launcher from %SERVER_BAT% ...
REM Drop PAUSE / pause lines so "Press any key" cannot block the restart loop.
REM Keep the launcher beside StartServer64.bat so %%~dp0 paths still work.
findstr /V /I /R /C:"^[ 	]*pause" "%SERVER_DIR%%SERVER_BAT%" > "%NOPAUSE_BAT%"
if not exist "%NOPAUSE_BAT%" (
	echo ERROR: Failed to create "%NOPAUSE_BAT%"
	pause
	exit /b 1
)

echo [%date% %time%] Starting Project Zomboid server from "%CD%" ...
call "%NOPAUSE_BAT%"
set "EXIT_CODE=%ERRORLEVEL%"

echo.
echo [%date% %time%] Server process exited with code %EXIT_CODE%.
echo Restarting in %RESTART_DELAY_SECONDS% seconds... (Ctrl+C to stop the wrapper)
timeout /t %RESTART_DELAY_SECONDS% /nobreak >nul
goto loop
