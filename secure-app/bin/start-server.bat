@echo off
REM 🚀 SECURE UNIVERSAL ANALYSIS SERVER 2025 - Professional Launcher
REM Professional enterprise-grade server startup script

echo.
echo ============================================
echo 🚀 SECURE ANALYSIS SERVER 2025 - Professional
echo ============================================
echo.

cd /d "%~dp0\.."

REM Vérifier si Deno est installé
deno --version > nul 2>&1
if errorlevel 1 (
    echo ❌ Deno runtime not found
    echo.
    echo 💡 DENO INSTALLATION REQUIRED:
    echo    winget install deno
    echo    or visit: https://deno.land/manual/getting_started/installation
    echo.
    pause
    exit /b 1
) else (
    echo ✅ Deno runtime available
    deno --version
)

echo.
echo 🔒 ENTERPRISE SECURITY FEATURES:
echo    • Deno Runtime Sandbox with explicit permissions
echo    • Configuration-driven security policies
echo    • Professional directory structure
echo    • Centralized configuration management
echo    • Type-safe request validation
echo    • Professional logging and monitoring
echo.

echo 🌐 Starting Professional Analysis Server...
echo 📊 API available at: http://localhost:8080
echo 🛑 Stop: Ctrl+C
echo.

deno run --allow-net --allow-run --allow-read --allow-write src/server/app.server.ts

pause