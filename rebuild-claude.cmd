@echo off
setlocal
cd /d "%~dp0"

REM ===  Delete everything for this project and rebuild with --no-cache  ===

echo ============================================================
echo  This will DELETE for this project:
echo    - the container
echo    - the volumes claude-config and claude-cache
echo      Claude login/onboarding state and the browser cache
echo    - the image claude-dangerous:latest
echo  then rebuild the image from scratch with --no-cache.
echo.
echo  Note: the image is shared by every cloned project.
echo ============================================================
echo.
choice /c YN /m "Proceed"
if errorlevel 2 goto cancelled

docker info >nul 2>&1
if not errorlevel 1 goto docker_ok
echo Docker is not running. Starting Docker Desktop...
if not exist "C:\Program Files\Docker\Docker\Docker Desktop.exe" (
  echo [ERROR] Docker Desktop not found. Start it manually and re-run.
  pause
  exit /b 1
)
start "" "C:\Program Files\Docker\Docker\Docker Desktop.exe"
echo Waiting for Docker to be ready...
powershell -NoProfile -Command "while ($true) { docker info *> $null; if ($LASTEXITCODE -eq 0) { break }; Start-Sleep -Seconds 3 }"
:docker_ok

echo.
choice /c YN /m "Keep your sessions (back them up to .claude-sessions before deleting)"
if errorlevel 2 goto skip_sessions
echo Backing up sessions to .claude-sessions ...
docker compose run --rm claude bash -lc "mkdir -p /workspace/.claude-sessions; cd /home/node/.claude 2>/dev/null && for s in projects sessions session-env history.jsonl; do [ -e $s ] && cp -r $s /workspace/.claude-sessions/; done; echo Sessions backed up."
:skip_sessions

echo.
echo [1/3] Removing containers and volumes...
docker compose down -v

echo [2/3] Removing image claude-dangerous:latest...
docker rmi claude-dangerous:latest >nul 2>&1

echo [3/3] Rebuilding with --no-cache. This takes several minutes...
docker compose build --no-cache
if errorlevel 1 (
  echo [ERROR] Build failed.
  pause
  exit /b 1
)

echo.
echo Done. Run start-claude-dangerously.cmd or start-claude-normal.cmd to launch Claude.
pause
endlocal
exit /b 0

:cancelled
echo Cancelled.
pause
endlocal
exit /b 0
