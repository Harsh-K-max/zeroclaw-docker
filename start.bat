@echo off
setlocal enabledelayedexpansion

:: ====================================================================
:: ZeroClaw Launcher for Windows
:: ====================================================================
:: This script starts Docker and launches the ZeroClaw Telegram Bot.
:: ====================================================================

:: Get the directory where this script is located
set "BASE_DIR=%~dp0"
:: Remove trailing backslash if present
if "%BASE_DIR:~-1%"=="\" set "BASE_DIR=%BASE_DIR:~0,-1%"

set "MODEL_NAME=%~1"
set "DOCKER_IMAGE=zeroclaw-bootstrap:local"
set "DATA_DIR=%BASE_DIR%\.zeroclaw-docker"

echo ============================================================
echo           Z E R O C L A W   L A U N C H E R
echo ============================================================
echo [*] Script location: %BASE_DIR%
echo [*] Data location:   %DATA_DIR%

:: 1. Check if Docker command exists
where docker >nul 2>&1
if %errorlevel% NEQ 0 (
    echo [!] 'docker' command not found. Please install Docker Desktop.
    pause
    exit /b 1
)

:: 2. Check if Docker daemon is running
echo [*] Checking Docker daemon...
docker info >nul 2>&1
if %errorlevel% NEQ 0 (
    echo [!] Docker is installed but not running.
    echo [*] Attempting to start Docker Desktop...
    
    :: Try common install paths
    set "DOCKER_PATH=C:\Program Files\Docker\Docker\Docker Desktop.exe"
    if not exist "!DOCKER_PATH!" set "DOCKER_PATH=%ProgramFiles%\Docker\Docker\Docker Desktop.exe"

    if exist "!DOCKER_PATH!" (
        start "" "!DOCKER_PATH!"
        echo [!] Docker Desktop starting... 
        echo [!] Please wait for the 'Whale' icon to turn solid in your taskbar,
        echo     then run this script again.
    ) else (
        echo [!] Docker Desktop executable not found in default paths.
        echo [!] Please start Docker Desktop manually.
    )
    pause
    exit /b 1
)

:: 3. Check if the ZeroClaw image exists
echo [*] Verifying ZeroClaw image...
docker image inspect %DOCKER_IMAGE% >nul 2>&1
if %errorlevel% NEQ 0 (
    echo [!] ZeroClaw Docker image not found.
    echo [!] Running bootstrap to build it...
    cd /d "%BASE_DIR%"
    bash ./scripts/bootstrap.sh --docker
    if %errorlevel% NEQ 0 (
        echo [!] Build failed. Please check the errors above.
        pause
        exit /b 1
    )
)

:: 4. If a model name was provided, update the config.toml
if not "!MODEL_NAME!"=="" (
    echo [*] Switching model to: !MODEL_NAME!
    docker run --rm ^
      -v "%DATA_DIR%/.zeroclaw:/zeroclaw-data/.zeroclaw" ^
      %DOCKER_IMAGE% sed -i "s/default_model = .*/default_model = \"!MODEL_NAME!\"/" /zeroclaw-data/.zeroclaw/config.toml
    
    if !errorlevel! EQU 0 (
        echo [v] Model updated successfully.
    ) else (
        echo [!] Failed to update model. Using previous configuration.
    )
)

:: 5. Launch the ZeroClaw Daemon
echo [*] Starting ZeroClaw Telegram Bot Daemon...
echo [*] Press Ctrl+C to stop the bot.
echo.

docker run --rm -it ^
  -e HOME=/zeroclaw-data ^
  -e ZEROCLAW_WORKSPACE=/zeroclaw-data/workspace ^
  -v "%DATA_DIR%/.zeroclaw:/zeroclaw-data/.zeroclaw" ^
  -v "%DATA_DIR%/workspace:/zeroclaw-data/workspace" ^
  -p 3000:3000 ^
  %DOCKER_IMAGE% daemon

pause
