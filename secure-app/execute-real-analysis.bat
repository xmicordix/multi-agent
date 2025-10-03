@echo off
REM 🚀 EXÉCUTION RÉELLE DE L'ANALYSE UNIVERSELLE
REM Lance le script PowerShell avec Claude Code CLI

echo.
echo ========================================
echo 🚀 ANALYSE RÉELLE - CLAUDE CODE CLI
echo ========================================
echo.

cd /d "%~dp0"

echo ⚠️  ATTENTION: Cette analyse va consommer de vrais tokens Claude !
echo.
set /p confirm="Continuer avec l'analyse réelle? [y/N]: "
if /i not "%confirm%"=="y" (
    echo Analyse annulée
    pause
    exit /b 0
)

echo.
echo 🔍 Lancement de l'analyse universelle pour le système "sessions"...

powershell -ExecutionPolicy Bypass -Command "& { .\universal-system-analysis.ps1 -TargetSystem 'sessions' -MaxConcurrentSessions 2 -TimeoutMinutes 5 -ClaudeModel 'sonnet' }"

echo.
echo 🎉 Analyse terminée!
echo 📁 Vérifiez les fichiers JSON générés dans ce répertoire
echo.
pause