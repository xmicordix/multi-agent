# 🚀 INSTALLATION DENO 2025 - RUNTIME SÉCURISÉ
# Script d'installation automatique de Deno pour Universal System Analysis

Write-Host "🚀 INSTALLATION DENO 2025" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

# Vérifier si Deno est déjà installé
try {
    $denoVersion = deno --version 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Deno est déjà installé:" -ForegroundColor Green
        Write-Host $denoVersion
        Write-Host ""

        $update = Read-Host "Voulez-vous mettre à jour vers la dernière version? [y/N]"
        if ($update -ine "y") {
            Write-Host "Installation annulée" -ForegroundColor Yellow
            exit 0
        }
    }
} catch {
    Write-Host "🔍 Deno non détecté, installation en cours..." -ForegroundColor Yellow
}

Write-Host "📥 Téléchargement et installation de Deno..." -ForegroundColor Yellow

try {
    # Installation officielle Deno
    irm https://deno.land/install.ps1 | iex

    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "✅ Deno installé avec succès!" -ForegroundColor Green

        # Vérifier l'installation
        $env:PATH += ";$env:USERPROFILE\.deno\bin"

        Write-Host ""
        Write-Host "🔍 Vérification de l'installation..." -ForegroundColor Cyan
        deno --version

        Write-Host ""
        Write-Host "🎯 PROCHAINES ÉTAPES:" -ForegroundColor Cyan
        Write-Host "1. Redémarrez votre terminal/PowerShell" -ForegroundColor White
        Write-Host "2. Exécutez: start-secure-server.bat" -ForegroundColor White
        Write-Host "3. Ouvrez: secure-frontend.html" -ForegroundColor White
        Write-Host ""
        Write-Host "📚 Documentation: https://deno.land/manual" -ForegroundColor Gray

    } else {
        throw "Installation échouée"
    }

} catch {
    Write-Host ""
    Write-Host "❌ Erreur lors de l'installation: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "🔧 INSTALLATION MANUELLE:" -ForegroundColor Yellow
    Write-Host "1. Visitez: https://deno.land/manual/getting_started/installation" -ForegroundColor White
    Write-Host "2. Ou utilisez: winget install deno" -ForegroundColor White
    exit 1
}

Write-Host ""
Write-Host "🎉 Installation terminée!" -ForegroundColor Green
Read-Host "Appuyez sur Entrée pour continuer"