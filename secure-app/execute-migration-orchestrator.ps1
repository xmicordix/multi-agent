# 🎯 MIGRATION ORCHESTRATOR - EXÉCUTION AUTOMATIQUE COMPLÈTE
# Revolutionary Control Center - Migration Phase Executor 2025

param(
    [string]$ProjectPath = (Get-Location).Path,
    [string]$ClaudeModel = "sonnet",
    [int]$TimeoutMinutes = 15,
    [string]$ExecutionMode = "safe", # safe, aggressive, validation-only
    [switch]$DryRun = $false,
    [switch]$ContinueFromPhase = $false,
    [int]$StartFromPhase = 1
)

# Configuration
$ErrorActionPreference = "Continue"
$ProgressPreference = "Continue"

# Chemins critiques
$ScriptsPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Resolve-Path (Join-Path $ScriptsPath "..")
$ResultsPath = $ScriptsPath
$LogsPath = Join-Path $ScriptsPath "execution-logs"

# Créer répertoire logs
if (!(Test-Path $LogsPath)) {
    New-Item -ItemType Directory -Path $LogsPath -Force | Out-Null
}

$ExecutionId = Get-Date -Format "yyyyMMdd-HHmmss"
$LogFile = Join-Path $LogsPath "migration-execution-$ExecutionId.log"

function Write-ExecutionLog {
    param([string]$Message, [string]$Level = "INFO")
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogEntry = "[$Timestamp] [$Level] $Message"
    Write-Host $LogEntry
    Add-Content -Path $LogFile -Value $LogEntry -Encoding UTF8
}

function Test-ClaudeCodeCLI {
    try {
        $version = claude --version 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-ExecutionLog "✅ Claude Code CLI disponible: $version"
            return $true
        }
    } catch {}

    Write-ExecutionLog "❌ Claude Code CLI non disponible" "ERROR"
    return $false
}

function Get-LatestAnalysisResults {
    Write-ExecutionLog "🔍 Recherche des résultats d'analyse les plus récents..."

    $analysisPattern = "COMPLETE-SYSTEM-IMPACT-ANALYSIS-*.json"
    $analysisFiles = Get-ChildItem -Path $ResultsPath -Name $analysisPattern | Sort-Object LastWriteTime -Descending

    if ($analysisFiles.Count -eq 0) {
        Write-ExecutionLog "⚠️ Aucun résultat d'analyse trouvé. Lancement de l'analyse..." "WARNING"
        return $null
    }

    $latestAnalysis = $analysisFiles[0]
    $analysisPath = Join-Path $ResultsPath $latestAnalysis
    Write-ExecutionLog "📊 Utilisation de l'analyse: $latestAnalysis"

    return $analysisPath
}

function Update-MigrationPhases {
    param([string]$AnalysisResultPath)

    Write-ExecutionLog "🔄 Mise à jour des phases de migration basée sur l'analyse..."

    try {
        $updateScript = Join-Path $ScriptsPath "update-phases-from-analysis.ps1"
        if (!(Test-Path $updateScript)) {
            Write-ExecutionLog "❌ Script de mise à jour des phases introuvable" "ERROR"
            return $false
        }

        & $updateScript -AnalysisResultPath $AnalysisResultPath -ProjectPath $ProjectRoot

        if ($LASTEXITCODE -eq 0) {
            Write-ExecutionLog "✅ Phases mises à jour avec succès"
            return $true
        } else {
            Write-ExecutionLog "❌ Échec de la mise à jour des phases" "ERROR"
            return $false
        }
    } catch {
        Write-ExecutionLog "❌ Erreur lors de la mise à jour des phases: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

function Get-MigrationPhases {
    Write-ExecutionLog "📋 Récupération des phases de migration..."

    $phases = @()
    $phasePattern = "MIGRATION_PHASE_*_*.md"
    $phaseFiles = Get-ChildItem -Path $ProjectRoot -Name $phasePattern | Sort-Object Name

    foreach ($phaseFile in $phaseFiles) {
        if ($phaseFile -match "MIGRATION_PHASE_(\d+)_(.+)\.md") {
            $phaseNumber = [int]$matches[1]
            $phaseName = $matches[2]
            $phasePath = Join-Path $ProjectRoot $phaseFile

            $phases += @{
                Number = $phaseNumber
                Name = $phaseName
                FileName = $phaseFile
                Path = $phasePath
                Executed = $false
            }
        }
    }

    $sortedPhases = $phases | Sort-Object Number
    Write-ExecutionLog "📊 $($sortedPhases.Count) phases de migration détectées"

    return $sortedPhases
}

function Execute-MigrationPhase {
    param(
        [hashtable]$Phase,
        [string]$ExecutionMode,
        [bool]$DryRun
    )

    $phaseNumber = $Phase.Number
    $phaseName = $Phase.Name
    $phasePath = $Phase.Path

    Write-ExecutionLog "🚀 Exécution Phase $phaseNumber : $phaseName"

    if ($DryRun) {
        Write-ExecutionLog "🧪 MODE DRY-RUN : Simulation de l'exécution" "WARNING"
        Start-Sleep 2
        return $true
    }

    # Construire le prompt pour Claude Code CLI
    $claudePrompt = @"
MISSION CRITIQUE: Exécuter la Phase $phaseNumber de la migration session management

CONTEXTE:
- Revolutionary Control Center IDE Migration
- Phase: $phaseName
- Mode d'exécution: $ExecutionMode
- Document de référence: $($Phase.FileName)

INSTRUCTIONS OBLIGATOIRES:
1. Lire intégralement le document $($Phase.FileName)
2. Exécuter TOUS les points de la phase dans l'ordre
3. Valider chaque étape avant de passer à la suivante
4. En cas d'erreur, appliquer les procédures de rollback
5. Documenter tous les changements effectués
6. Valider que la phase est 100% complète

SÉCURITÉ:
- Ne pas supprimer de fichiers sans validation
- Faire des backups avant modifications critiques
- Tester après chaque changement majeur
- Arrêter immédiatement si erreur critique

RÉPONSE ATTENDUE:
- ✅ Phase complétée avec succès
- ❌ Phase échouée avec détails de l'erreur
- 📋 Résumé des actions effectuées

Commencer l'exécution maintenant.
"@

    try {
        # Créer une session Claude dédiée pour cette phase
        $sessionId = "migration-phase-$phaseNumber-$ExecutionId"
        $claudeArgs = @(
            "--session-id", $sessionId
            "--model", $ClaudeModel
            "--timeout", "$($TimeoutMinutes * 60)"
            "--working-directory", $ProjectRoot.Path
        )

        Write-ExecutionLog "💬 Lancement session Claude: $sessionId"

        # Exécuter la commande Claude
        $claudeOutput = & claude @claudeArgs $claudePrompt 2>&1
        $claudeExitCode = $LASTEXITCODE

        # Logger la sortie Claude
        $phaseLogFile = Join-Path $LogsPath "phase-$phaseNumber-$ExecutionId.log"
        $claudeOutput | Out-File -FilePath $phaseLogFile -Encoding UTF8

        if ($claudeExitCode -eq 0) {
            Write-ExecutionLog "✅ Phase $phaseNumber exécutée avec succès"

            # Analyser la sortie pour vérifier le succès
            $outputText = $claudeOutput -join "`n"
            if ($outputText -match "✅.*[Cc]omplétée?" -or $outputText -match "✅.*[Ss]uccès") {
                return $true
            } elseif ($outputText -match "❌.*[Éé]chec" -or $outputText -match "❌.*[Ee]rreur") {
                Write-ExecutionLog "⚠️ Phase $phaseNumber signale un échec dans sa sortie" "WARNING"
                return $false
            } else {
                Write-ExecutionLog "⚠️ Phase $phaseNumber : statut incertain, validation manuelle requise" "WARNING"
                return $null # Statut incertain
            }
        } else {
            Write-ExecutionLog "❌ Phase $phaseNumber échouée (exit code: $claudeExitCode)" "ERROR"
            return $false
        }
    } catch {
        Write-ExecutionLog "❌ Erreur lors de l'exécution de la phase $phaseNumber : $($_.Exception.Message)" "ERROR"
        return $false
    }
}

function Execute-ValidationTests {
    Write-ExecutionLog "🧪 Exécution des tests de validation..."

    try {
        # Tests système de base
        $testCommands = @(
            @{ Name = "TypeScript Compilation"; Command = "npm run type-check" },
            @{ Name = "Unit Tests"; Command = "npm run test" },
            @{ Name = "Build Test"; Command = "npm run build" }
        )

        $allTestsPassed = $true

        foreach ($test in $testCommands) {
            Write-ExecutionLog "🔍 Test: $($test.Name)"

            $testResult = Invoke-Expression $test.Command 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-ExecutionLog "✅ $($test.Name) : SUCCÈS"
            } else {
                Write-ExecutionLog "❌ $($test.Name) : ÉCHEC" "ERROR"
                $allTestsPassed = $false
            }
        }

        return $allTestsPassed
    } catch {
        Write-ExecutionLog "❌ Erreur lors des tests de validation: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

function Show-ExecutionSummary {
    param([hashtable[]]$Phases, [bool]$AllTestsPassed)

    Write-ExecutionLog "📊 RÉSUMÉ DE L'EXÉCUTION"
    Write-ExecutionLog "================================"

    $totalPhases = $Phases.Count
    $successfulPhases = ($Phases | Where-Object { $_.Executed -eq $true }).Count
    $failedPhases = ($Phases | Where-Object { $_.Executed -eq $false }).Count
    $uncertainPhases = ($Phases | Where-Object { $_.Executed -eq $null }).Count

    Write-ExecutionLog "📈 Phases totales: $totalPhases"
    Write-ExecutionLog "✅ Phases réussies: $successfulPhases"
    Write-ExecutionLog "❌ Phases échouées: $failedPhases"
    Write-ExecutionLog "⚠️ Phases incertaines: $uncertainPhases"

    if ($AllTestsPassed) {
        Write-ExecutionLog "✅ Tests de validation: TOUS RÉUSSIS"
    } else {
        Write-ExecutionLog "❌ Tests de validation: ÉCHECS DÉTECTÉS"
    }

    $successRate = [math]::Round(($successfulPhases / $totalPhases) * 100, 2)
    Write-ExecutionLog "📊 Taux de réussite: $successRate%"

    Write-ExecutionLog "📁 Logs détaillés: $LogsPath"
    Write-ExecutionLog "================================"
}

# ===============================
# EXÉCUTION PRINCIPALE
# ===============================

Write-ExecutionLog "🎯 DÉMARRAGE MIGRATION ORCHESTRATOR"
Write-ExecutionLog "Mode d'exécution: $ExecutionMode"
Write-ExecutionLog "Projet: $ProjectRoot"

# Vérifications préliminaires
if (!(Test-ClaudeCodeCLI)) {
    Write-ExecutionLog "❌ Impossible de continuer sans Claude Code CLI" "ERROR"
    exit 1
}

# Récupérer les résultats d'analyse
$analysisPath = Get-LatestAnalysisResults

if ($null -eq $analysisPath) {
    Write-ExecutionLog "⚠️ Lancement de l'analyse parallèle d'abord..." "WARNING"
    $parallelScript = Join-Path $ScriptsPath "parallel-system-analysis.ps1"

    if (Test-Path $parallelScript) {
        & $parallelScript -ProjectPath $ProjectRoot -MaxConcurrentSessions 5 -TimeoutMinutes 10
        $analysisPath = Get-LatestAnalysisResults
    }

    if ($null -eq $analysisPath) {
        Write-ExecutionLog "❌ Impossible d'obtenir les résultats d'analyse" "ERROR"
        exit 1
    }
}

# Mettre à jour les phases basées sur l'analyse
if (!(Update-MigrationPhases -AnalysisResultPath $analysisPath)) {
    Write-ExecutionLog "❌ Échec de la mise à jour des phases" "ERROR"
    exit 1
}

# Récupérer les phases de migration
$migrationPhases = Get-MigrationPhases

if ($migrationPhases.Count -eq 0) {
    Write-ExecutionLog "❌ Aucune phase de migration trouvée" "ERROR"
    exit 1
}

# Filtrer les phases selon StartFromPhase
if ($ContinueFromPhase -and $StartFromPhase -gt 1) {
    $migrationPhases = $migrationPhases | Where-Object { $_.Number -ge $StartFromPhase }
    Write-ExecutionLog "🔄 Continuation depuis la phase $StartFromPhase"
}

# Exécution des phases
Write-ExecutionLog "🚀 DÉBUT DE L'EXÉCUTION DES PHASES"

foreach ($phase in $migrationPhases) {
    $result = Execute-MigrationPhase -Phase $phase -ExecutionMode $ExecutionMode -DryRun $DryRun

    if ($result -eq $true) {
        $phase.Executed = $true
        Write-ExecutionLog "✅ Phase $($phase.Number) complétée"
    } elseif ($result -eq $false) {
        $phase.Executed = $false
        Write-ExecutionLog "❌ Phase $($phase.Number) échouée" "ERROR"

        if ($ExecutionMode -eq "safe") {
            Write-ExecutionLog "🛡️ Mode sûr: Arrêt sur échec" "WARNING"
            break
        }
    } else {
        $phase.Executed = $null
        Write-ExecutionLog "⚠️ Phase $($phase.Number) : statut incertain" "WARNING"
    }

    # Pause entre phases pour stabilité
    Start-Sleep 3
}

# Tests de validation finaux
Write-ExecutionLog "🧪 VALIDATION FINALE"
$validationPassed = Execute-ValidationTests

# Résumé final
Show-ExecutionSummary -Phases $migrationPhases -AllTestsPassed $validationPassed

if ($validationPassed -and ($migrationPhases | Where-Object { $_.Executed -eq $false }).Count -eq 0) {
    Write-ExecutionLog "🎉 MIGRATION COMPLÈTE AVEC SUCCÈS !" "SUCCESS"
    exit 0
} else {
    Write-ExecutionLog "⚠️ Migration incomplète ou avec erreurs. Vérifiez les logs." "WARNING"
    exit 1
}