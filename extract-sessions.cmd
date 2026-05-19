@echo off
setlocal
cd /d "%~dp0"

REM ===  Extract sessions from the container volume into .claude-sessions  ===

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

echo Extracting sessions from the container volume to .claude-sessions ...
docker compose run --rm claude bash -lc "mkdir -p /workspace/.claude-sessions; cd /home/node/.claude 2>/dev/null && for s in projects sessions session-env history.jsonl; do [ -e $s ] && cp -r $s /workspace/.claude-sessions/; done; echo Sessions extracted."

echo.
echo Done. Your sessions are saved in the .claude-sessions folder.
echo Run restore-sessions.cmd later to copy them back into a container.
pause
endlocal
