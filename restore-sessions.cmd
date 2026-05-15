@echo off
setlocal
cd /d "%~dp0"

REM ===  Copy backed-up sessions from .claude-sessions into the container volume  ===

if not exist ".claude-sessions" (
  echo [ERROR] No .claude-sessions folder found in this project.
  echo Run rebuild-claude.cmd and choose to keep your sessions to create one.
  pause
  exit /b 1
)

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

echo Copying sessions into the container volume...
docker compose run --rm claude bash -lc "cp -r /workspace/.claude-sessions/. /home/node/.claude/ && echo Sessions copied into the container."

set "RESUME_PROMPT=Look in /home/node/.claude/projects/ for the most recent .jsonl transcript, read it, and continue our previous session from where we left off."
<nul set /p="%RESUME_PROMPT%" | clip

echo.
echo ============================================================
echo  Sessions copied into the container.
echo.
echo  Claude's built-in --resume may not list a restored session,
echo  so a resume prompt has been copied to your clipboard.
echo.
echo  Next steps:
echo   1. Run start-claude-dangerously.cmd or start-claude-normal.cmd.
echo      Pick No if it asks about restoring sessions again.
echo   2. When Claude is ready, paste the prompt with Ctrl+V and send it.
echo.
echo  The prompt:
echo  %RESUME_PROMPT%
echo ============================================================
pause
endlocal
