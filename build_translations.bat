@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

echo.
echo [INFO] DBI Patcher Translation Builder
echo ====================================

where make >nul 2>&1
if errorlevel 1 (
    echo [ERROR] make is not installed. Please install make first.
    echo         Install make from Cygwin or MinGW
    pause
    exit /b 1
)

:menu
echo.
echo Select an option:
echo   1. Build all translations
echo   2. Build specific language
echo   3. List available languages
echo   4. Clean build files
echo   5. Exit
echo.
set /p choice="Enter your choice (1-5): "

if "%choice%"=="1" goto build_all
if "%choice%"=="2" goto build_single
if "%choice%"=="3" goto list_languages
if "%choice%"=="4" goto clean_build
if "%choice%"=="5" goto exit_script

echo Invalid choice, please try again.
goto menu

:build_all
echo.
echo [INFO] Building main program...
make --no-print-directory
if errorlevel 1 (
    echo [ERROR] Failed to build main program
    pause
    exit /b 1
)
echo [SUCCESS] Main program built successfully

echo.
echo [INFO] Building all translations...
make translate-all --no-print-directory
if errorlevel 1 (
    echo [ERROR] Failed to build translations
    pause
    exit /b 1
)
echo [SUCCESS] All translations built successfully
goto success

:build_single
echo.
echo [INFO] Available languages:
make list-languages --no-print-directory
echo.
set /p lang="Enter language code: "

echo.
echo [INFO] Building main program...
make --no-print-directory
if errorlevel 1 (
    echo [ERROR] Failed to build main program
    pause
    exit /b 1
)

echo.
echo [INFO] Building translation for language: %lang%
make translate-%lang% --no-print-directory
if errorlevel 1 (
    echo [ERROR] Failed to build translation for %lang%
    pause
    exit /b 1
)
echo [SUCCESS] Translation for %lang% built successfully
goto success

:list_languages
echo.
make list-languages --no-print-directory
goto menu

:clean_build
echo.
echo [INFO] Cleaning build files...
make clean --no-print-directory
make clean-translate --no-print-directory
echo [SUCCESS] Clean completed
goto menu

:success
echo.
echo ====================================
echo [SUCCESS] Build process completed!
echo ====================================
echo.
pause

:exit_script
exit /b 0