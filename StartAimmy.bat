@echo off
setlocal
title Aimmy - AI Aim Alignment Mechanism
color 0A

pushd "%~dp0"

echo ============================================
echo        Aimmy - Launcher Script
echo ============================================
echo.

:: Check for .NET SDK
dotnet --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] .NET SDK was not found in PATH.
    echo.
    echo Please install .NET 8 SDK from:
    echo https://dotnet.microsoft.com/en-us/download/dotnet/8.0
    echo.
    pause
    exit /b 1
)

echo [OK] .NET SDK found.
echo.

:: Determine build output directory and exe path
set "RELEASE_DIR=Aimmy2\bin\Release\net8.0-windows"
set "DEBUG_DIR=Aimmy2\bin\Debug\net8.0-windows"
set "EXE_PATH=%RELEASE_DIR%\YmmiaV2.exe"
set "EXE_PATH_DEBUG=%DEBUG_DIR%\YmmiaV2.exe"
set "TARGET_DIR="

:: Check if already built
if exist "%EXE_PATH%" (
    echo [OK] Pre-built Release binary found.
    set "TARGET_DIR=%RELEASE_DIR%"
    goto :copy_assets
)

if exist "%EXE_PATH_DEBUG%" (
    echo [OK] Debug binary found.
    set "TARGET_DIR=%DEBUG_DIR%"
    set "EXE_PATH=%EXE_PATH_DEBUG%"
    goto :copy_assets
)

:: No binary found, build from source
echo [INFO] No pre-built binary found. Building from source...
echo [INFO] This may take a few minutes on the first run.
echo.

dotnet build Aimmy2\Aimmy2.csproj -c Release
if errorlevel 1 (
    echo.
    echo [ERROR] Build failed.
    echo.
    echo Possible fixes:
    echo   1. Make sure .NET 8 SDK (x64) is installed.
    echo   2. Make sure Visual C++ Redistributable (x64) is installed.
    echo   3. Try opening Aimmy2.sln in Visual Studio and build manually.
    echo.
    pause
    exit /b 1
)

echo.
echo [OK] Build succeeded.
set "TARGET_DIR=%RELEASE_DIR%"
set "EXE_PATH=%RELEASE_DIR%\YmmiaV2.exe"

if not exist "%EXE_PATH%" (
    echo [ERROR] Build completed but executable not found at:
    echo         %EXE_PATH%
    echo.
    echo Try running manually: dotnet run --project Aimmy2\Aimmy2.csproj -c Release
    pause
    exit /b 1
)

:copy_assets
echo.

:: Copy models from project root to runtime bin/models directory
set "SRC_MODELS=%~dp0models"
set "DST_MODELS=%TARGET_DIR%\bin\models"

if not exist "%DST_MODELS%" mkdir "%DST_MODELS%"

if exist "%SRC_MODELS%\*.onnx" (
    set "MODEL_COUNT=0"
    for %%f in ("%SRC_MODELS%\*.onnx") do (
        if not exist "%DST_MODELS%\%%~nxf" (
            echo [COPY] %%~nxf
            copy "%%f" "%DST_MODELS%\" >nul
        )
    )
    echo [OK] Models synced to runtime directory.
) else (
    echo [WARN] No .onnx models found in project root "models\" folder.
    echo        You can place .onnx model files in: %DST_MODELS%
    echo        Or download models from Aimmy's built-in model store.
)

:: Copy configs from project root to runtime bin/configs directory
set "SRC_CONFIGS=%~dp0configs"
set "DST_CONFIGS=%TARGET_DIR%\bin\configs"

if not exist "%DST_CONFIGS%" mkdir "%DST_CONFIGS%"

if exist "%SRC_CONFIGS%\*.cfg" (
    for %%f in ("%SRC_CONFIGS%\*.cfg") do (
        if not exist "%DST_CONFIGS%\%%~nxf" (
            echo [COPY] %%~nxf
            copy "%%f" "%DST_CONFIGS%\" >nul
        )
    )
    echo [OK] Configs synced to runtime directory.
)

:: Launch Aimmy
echo.
echo [INFO] Launching Aimmy...
echo.
start "" "%EXE_PATH%"

echo [INFO] Aimmy launched successfully.
echo.

popd
endlocal
exit /b 0
