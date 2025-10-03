@echo off
REM 🚀 SECURE DENO SERVER LAUNCHER 2025
REM Lance le serveur sécurisé pour Universal System Analysis

echo.
echo ========================================
echo 🚀 SECURE DENO SERVER 2025
echo ========================================
echo.

REM Vérifier si Deno est installé
deno --version > nul 2>&1
if errorlevel 1 (
    echo ❌ Deno n'est pas installé
    echo.
    echo 💡 INSTALLATION DENO:
    echo irm https://deno.land/install.ps1 ^| iex
    echo.
    echo Ou visitez: https://deno.land/manual/getting_started/installation
    pause
    exit /b 1
) else (
    echo ✅ Deno disponible
    deno --version
)

echo.
echo 🔒 FONCTIONNALITÉS SÉCURISÉES:
echo    - Sandbox Deno avec permissions explicites
echo    - Validation stricte des entrées
echo    - Timeout automatique des commandes
echo    - Exécution PowerShell contrôlée
echo    - Logs de sécurité détaillés
echo.

cd /d "%~dp0"

echo 🚀 Démarrage du serveur sécurisé...
echo 📡 Serveur disponible sur: http://localhost:8080
echo 🛑 Arrêt: Ctrl+C
echo.

deno run --allow-net --allow-run --allow-read --allow-write deno-server.ts

pause