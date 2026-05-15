@echo off
setlocal
REM ===  Install VcXsrv - the X server for the Playwright browser  ===

where winget >nul 2>&1
if errorlevel 1 (
  echo [ERROR] winget was not found.
  echo Update Windows, or install "App Installer" from the Microsoft Store.
  pause
  exit /b 1
)

echo Installing VcXsrv via winget...
echo.
winget install --id marha.VcXsrv -e --accept-package-agreements --accept-source-agreements

echo.
echo VcXsrv is installed.
echo Next: launch XLaunch from the Start menu and configure it -
echo   Multiple windows  /  Start no client  /  Disable access control
pause
endlocal
