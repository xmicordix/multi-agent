@echo off
REM 🎯 UNIVERSAL SYSTEM ANALYSIS - GUI LAUNCHER
REM Lance l'interface graphique de configuration

echo.
echo ========================================
echo 🎯 UNIVERSAL SYSTEM ANALYSIS - GUI
echo ========================================
echo.

REM Vérifier que le fichier GUI existe
if not exist "gui-config-generator.html" (
    echo ❌ Fichier GUI introuvable: gui-config-generator.html
    pause
    exit /b 1
)

echo ✅ Interface graphique trouvée
echo 🚀 Ouverture de l'interface...

REM Ouvrir la GUI dans le navigateur par défaut
start "" "gui-config-generator.html"

echo.
echo 📋 INSTRUCTIONS D'UTILISATION:
echo.
echo 1. 🎯 Sélectionnez un preset ou configurez votre système
echo 2. 🔧 Générez la configuration JSON
echo 3. 🚀 Lancez l'analyse complète directement dans l'interface
echo 4. 📊 Suivez le progrès en temps réel
echo 5. ⚡ Exécutez les phases de migration automatiquement
echo.
echo 💡 Ou copiez la commande PowerShell pour exécution manuelle
echo 📁 Tous les résultats seront dans le répertoire scripts/
echo.
echo Interface web ouverte dans votre navigateur par défaut.

pause