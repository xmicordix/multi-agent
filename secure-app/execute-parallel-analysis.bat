@echo off
REM 🚀 EXECUTE PARALLEL ANALYSIS - BATCH LAUNCHER
REM Revolutionary Control Center - Exhaustive System Impact Analysis

echo.
echo ========================================
echo 🎯 PARALLEL SYSTEM ANALYSIS LAUNCHER
echo ========================================
echo.

REM Vérifier PowerShell disponible
powershell -Command "Write-Host '✅ PowerShell disponible' -ForegroundColor Green"
if errorlevel 1 (
    echo ❌ PowerShell non disponible
    pause
    exit /b 1
)

REM Vérifier Claude Code CLI disponible
claude --version > nul 2>&1
if errorlevel 1 (
    echo ❌ Claude Code CLI non disponible ou non dans PATH
    echo 💡 Installez Claude Code CLI: https://claude.ai/code
    pause
    exit /b 1
) else (
    echo ✅ Claude Code CLI disponible
)

echo.
echo 🚀 Lancement de l'analyse parallèle...
echo ⚠️  Ceci va lancer plusieurs sessions Claude simultanément
echo ⏰ Durée estimée: 5-10 minutes
echo.

REM Changer vers le répertoire du script
cd /d "%~dp0"

REM Lancer le script PowerShell principal
powershell -ExecutionPolicy Bypass -File "parallel-system-analysis.ps1" -ProjectPath "%~dp0.." -MaxConcurrentSessions 5 -TimeoutMinutes 10 -ClaudeModel "sonnet"

echo.
echo 🏁 Analyse terminée!
echo 📁 Vérifiez les fichiers de résultats dans le répertoire scripts/
echo.
pause