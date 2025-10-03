@echo off
REM 🎯 MIGRATION COMPLÈTE - ORCHESTRATEUR PRINCIPAL
REM Revolutionary Control Center - Pipeline d'Exécution Automatique 2025

echo.
echo ========================================
echo 🚀 MIGRATION ORCHESTRATOR - PIPELINE COMPLET
echo ========================================
echo.

REM Vérifications préliminaires
echo 🔍 Vérification de l'environnement...

powershell -Command "Write-Host '✅ PowerShell disponible' -ForegroundColor Green"
if errorlevel 1 (
    echo ❌ PowerShell non disponible
    pause
    exit /b 1
)

claude --version > nul 2>&1
if errorlevel 1 (
    echo ❌ Claude Code CLI non disponible
    echo 💡 Installez Claude Code CLI: https://claude.ai/code
    pause
    exit /b 1
) else (
    echo ✅ Claude Code CLI disponible
)

echo.
echo 🎯 PIPELINE DE MIGRATION AUTOMATIQUE
echo.
echo 📋 ÉTAPES:
echo    1. Analyse parallèle exhaustive (5-10 min)
echo    2. Mise à jour des phases basée sur l'analyse
echo    3. Exécution séquentielle sécurisée des phases
echo    4. Validation et tests finaux
echo.
echo ⚠️  ATTENTION: Ce processus va modifier le code source
echo 🔒 Mode sécurisé activé avec rollback automatique
echo.

set /p confirm="Continuer avec la migration complète? [y/N]: "
if /i not "%confirm%"=="y" (
    echo Migration annulée
    pause
    exit /b 0
)

echo.
echo 🚀 Lancement du pipeline complet...

cd /d "%~dp0"

REM ÉTAPE 1: Analyse parallèle
echo.
echo ========================================
echo 📊 ÉTAPE 1: ANALYSE PARALLÈLE EXHAUSTIVE
echo ========================================

powershell -ExecutionPolicy Bypass -File "parallel-system-analysis.ps1" -ProjectPath "%~dp0.." -MaxConcurrentSessions 5 -TimeoutMinutes 10

if errorlevel 1 (
    echo ❌ Échec de l'analyse parallèle
    echo 📁 Vérifiez les logs dans scripts/analysis-logs/
    pause
    exit /b 1
)

echo ✅ Analyse parallèle terminée avec succès

REM ÉTAPE 2 & 3: Exécution orchestrée
echo.
echo ========================================
echo 🎯 ÉTAPES 2-4: EXÉCUTION ORCHESTRÉE
echo ========================================

powershell -ExecutionPolicy Bypass -File "execute-migration-orchestrator.ps1" -ProjectPath "%~dp0.." -ExecutionMode "safe" -TimeoutMinutes 15

if errorlevel 1 (
    echo ❌ Échec de l'exécution orchestrée
    echo 📁 Vérifiez les logs dans scripts/execution-logs/
    echo 🔄 Rollback automatique en cours...
    pause
    exit /b 1
)

echo.
echo 🎉 MIGRATION COMPLÈTE TERMINÉE AVEC SUCCÈS!
echo.
echo 📊 RÉSULTATS:
echo    ✅ Analyse parallèle: Sessions management analysé
echo    ✅ Phases mises à jour: Basées sur l'analyse complète
echo    ✅ Exécution sécurisée: Toutes les phases exécutées
echo    ✅ Validation: Tests passés avec succès
echo.
echo 📁 Logs détaillés disponibles dans:
echo    - scripts/analysis-logs/
echo    - scripts/execution-logs/
echo.
echo 🎯 Le Revolutionary Control Center est maintenant migré!

pause