@echo off
setlocal
cd /d "%~dp0"

REM ===  Start Claude in a Docker container (normal mode)  ===

if not exist ".env" (
  echo [ERROR] .env not found in this folder.
  echo Copy .env.example to .env and set your CLAUDE_CODE_OAUTH_TOKEN.
  pause
  exit /b 1
)

docker info >nul 2>&1
if not errorlevel 1 goto docker_ok
echo Docker is not running. Starting Docker Desktop...
if not exist "C:\Program Files\Docker\Docker\Docker Desktop.exe" (
  echo [ERROR] Docker Desktop not found at the default path.
  echo Start Docker Desktop manually, then re-run this script.
  pause
  exit /b 1
)
start "" "C:\Program Files\Docker\Docker\Docker Desktop.exe"
echo Waiting for Docker to be ready...
powershell -NoProfile -Command "while ($true) { docker info *> $null; if ($LASTEXITCODE -eq 0) { break }; Start-Sleep -Seconds 3 }"
:docker_ok
echo Docker is ready.

tasklist /fi "imagename eq vcxsrv.exe" 2>nul | find /i "vcxsrv.exe" >nul
if errorlevel 1 echo [WARN] VcXsrv not detected - headed Playwright browser will not display.

docker image inspect claude-dangerous:latest >nul 2>&1
if not errorlevel 1 goto image_ok
echo Image not found - building it now. First run takes a few minutes...
docker compose build
if errorlevel 1 (
  echo [ERROR] Build failed.
  pause
  exit /b 1
)
:image_ok

echo.
echo Starting Claude in normal mode (permission prompts on)...
echo.
docker compose run --rm claude claude

echo.
echo Claude session ended.
pause
endlocal
