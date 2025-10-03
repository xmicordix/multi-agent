# 🎯 UNIVERSAL SYSTEM ANALYSIS - SYSTÈME UNIVERSEL D'ANALYSE PARALLÈLE
# Revolutionary Control Center - Analyse exhaustive pour TOUT refactoring 2025

param(
    [string]$ProjectPath = (Get-Location).Path,
    [string]$TargetSystem = "sessions", # sessions, projects, ui-components, database, etc.
    [string]$ClaudeModel = "sonnet",
    [int]$MaxConcurrentSessions = 5,
    [int]$TimeoutMinutes = 10,
    [string]$ConfigFile = $null, # Optionnel: fichier de config custom
    [switch]$CreateTemplate = $false
)

# Configuration des systèmes supportés
$SystemConfigurations = @{
    "sessions" = @{
        Name = "Session Management System"
        Description = "Analyse du système de gestion des sessions"
        Domains = @(
            @{ Name = "sessions"; Keywords = @("session", "SessionManager", "SessionBridge", "sessionStorage", "useSession") },
            @{ Name = "sqlite-database"; Keywords = @("sqlite", "database", "db", "SQL", "persistence") },
            @{ Name = "ui-ide-components"; Keywords = @("Panel", "Layout", "IDE", "Component", "UI") },
            @{ Name = "claude-cli-integration"; Keywords = @("claude", "CLI", "ChatInterface", "ClaudeCode") },
            @{ Name = "project-management"; Keywords = @("project", "ProjectService", "ProjectManager", "workspace") },
            @{ Name = "preload-ipc-handlers"; Keywords = @("preload", "IPC", "window.api", "contextBridge") }
        )
        CriticalFiles = @("src/main/index.ts", "src/preload/preload.ts", "src/main/services/session-manager.ts")
        RiskFactors = @("IPC communication", "Database migrations", "UI state management")
    }

    "projects" = @{
        Name = "Project Management System"
        Description = "Analyse du système de gestion des projets"
        Domains = @(
            @{ Name = "project-core"; Keywords = @("project", "ProjectService", "ProjectManager", "workspace", "createProject") },
            @{ Name = "file-system"; Keywords = @("fileSystem", "readFile", "writeFile", "FileTree", "explorer") },
            @{ Name = "git-integration"; Keywords = @("git", "GitIntegration", "repository", "commit", "branch") },
            @{ Name = "dependencies"; Keywords = @("dependency", "package.json", "npm", "node_modules", "DependencyManager") },
            @{ Name = "build-systems"; Keywords = @("build", "vite", "webpack", "rollup", "esbuild", "compile") },
            @{ Name = "project-ui"; Keywords = @("ProjectExplorer", "ProjectSettings", "ProjectSelector", "ProjectPanel") }
        )
        CriticalFiles = @("src/main/services/project-service.ts", "src/renderer/components/project/ProjectManager.tsx")
        RiskFactors = @("File system operations", "Git operations", "Build configuration")
    }

    "ui-components" = @{
        Name = "UI Components System"
        Description = "Analyse du système de composants UI"
        Domains = @(
            @{ Name = "layout-system"; Keywords = @("Layout", "Panel", "ActivityBar", "Sidebar", "Header") },
            @{ Name = "editor-components"; Keywords = @("Editor", "Monaco", "IDEEditor", "CodeEditor") },
            @{ Name = "terminal-components"; Keywords = @("Terminal", "IntegratedTerminal", "TerminalPanel", "shell") },
            @{ Name = "chat-components"; Keywords = @("Chat", "ChatInterface", "MessageRenderer", "ClaudeChat") },
            @{ Name = "theme-system"; Keywords = @("theme", "ThemeProvider", "dark", "light", "styling") },
            @{ Name = "state-management"; Keywords = @("useState", "useContext", "Zustand", "store", "state") }
        )
        CriticalFiles = @("src/renderer/components/RevolutionaryIDE.tsx", "src/renderer/components/ide/IDELayout.tsx")
        RiskFactors = @("Component dependencies", "State management", "Theme consistency")
    }

    "database" = @{
        Name = "Database System"
        Description = "Analyse du système de base de données"
        Domains = @(
            @{ Name = "sqlite-core"; Keywords = @("sqlite", "database", "db", "SQL", "query") },
            @{ Name = "data-models"; Keywords = @("model", "schema", "table", "entity", "migration") },
            @{ Name = "persistence-layer"; Keywords = @("persistence", "storage", "save", "load", "sync") },
            @{ Name = "data-access"; Keywords = @("repository", "DAO", "service", "API", "CRUD") },
            @{ Name = "data-validation"; Keywords = @("validation", "constraint", "foreign key", "integrity") },
            @{ Name = "backup-recovery"; Keywords = @("backup", "recovery", "export", "import", "restore") }
        )
        CriticalFiles = @("src/main/services/historical-data-storage.ts", "revolutionary-data.db")
        RiskFactors = @("Data integrity", "Migration scripts", "Backup procedures")
    }

    "claude-integration" = @{
        Name = "Claude Integration System"
        Description = "Analyse du système d'intégration Claude"
        Domains = @(
            @{ Name = "claude-cli-bridge"; Keywords = @("claude", "CLI", "ClaudeCodeBridge", "executeClaudeCommand") },
            @{ Name = "chat-interface"; Keywords = @("ChatInterface", "MessageRenderer", "ChatStream", "conversation") },
            @{ Name = "context-sharing"; Keywords = @("context", "workspace", "shareContext", "sessionData") },
            @{ Name = "command-integration"; Keywords = @("command", "executeCommand", "terminal", "shell") },
            @{ Name = "ai-features"; Keywords = @("AI", "assistance", "completion", "suggestion", "copilot") },
            @{ Name = "session-sync"; Keywords = @("sync", "synchronization", "session", "state") }
        )
        CriticalFiles = @("src/main/services/claude-cli-manager.ts", "src/renderer/components/chat/ChatInterface.tsx")
        RiskFactors = @("CLI integration", "Context management", "Session synchronization")
    }
}

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$Timestamp] [$Level] $Message"
}

function Create-ConfigTemplate {
    param([string]$SystemName)

    $templatePath = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) "config-$SystemName.json"

    if ($SystemConfigurations.ContainsKey($SystemName)) {
        $config = $SystemConfigurations[$SystemName]
    } else {
        $config = @{
            Name = "$SystemName System"
            Description = "Analyse du système $SystemName"
            Domains = @(
                @{ Name = "$SystemName-core"; Keywords = @($SystemName, "core", "manager", "service") },
                @{ Name = "$SystemName-ui"; Keywords = @("component", "UI", "interface", "panel") },
                @{ Name = "$SystemName-data"; Keywords = @("data", "storage", "persistence", "model") }
            )
            CriticalFiles = @("src/main/services/$SystemName-service.ts")
            RiskFactors = @("System integration", "Data consistency", "UI compatibility")
        }
    }

    $configJson = $config | ConvertTo-Json -Depth 10
    Set-Content -Path $templatePath -Value $configJson -Encoding UTF8

    Write-Log "✅ Template de configuration créé: $templatePath"
    Write-Log "💡 Éditez ce fichier puis relancez avec -ConfigFile `"$templatePath`""

    return $templatePath
}

function Load-SystemConfiguration {
    param([string]$SystemName, [string]$ConfigFile)

    if ($ConfigFile -and (Test-Path $ConfigFile)) {
        Write-Log "📁 Chargement de la configuration depuis: $ConfigFile"
        try {
            $config = Get-Content -Path $ConfigFile -Raw | ConvertFrom-Json
            return $config
        } catch {
            Write-Log "❌ Erreur lors du chargement du fichier de config: $($_.Exception.Message)" "ERROR"
            return $null
        }
    }

    if ($SystemConfigurations.ContainsKey($SystemName)) {
        Write-Log "📋 Utilisation de la configuration prédéfinie pour: $SystemName"
        return $SystemConfigurations[$SystemName]
    }

    Write-Log "❌ Système '$SystemName' non supporté et aucun fichier de config fourni" "ERROR"
    Write-Log "💡 Systèmes supportés: $($SystemConfigurations.Keys -join ', ')" "INFO"
    Write-Log "💡 Ou utilisez -CreateTemplate pour créer un template" "INFO"
    return $null
}

function Generate-DomainAnalysisPrompt {
    param([hashtable]$Domain, [hashtable]$SystemConfig, [string]$ProjectPath)

    $keywords = $Domain.Keywords -join '", "'
    $criticalFiles = $SystemConfig.CriticalFiles -join '", "'
    $riskFactors = $SystemConfig.RiskFactors -join '", "'

    return @"
MISSION CRITIQUE: Analyse exhaustive du domaine '$($Domain.Name)' dans le système '$($SystemConfig.Name)'

CONTEXTE SYSTÈME:
- Projet: Revolutionary Control Center
- Système cible: $($SystemConfig.Name)
- Description: $($SystemConfig.Description)
- Domaine d'analyse: $($Domain.Name)

MÉTHODOLOGIE D'ANALYSE:
1. **Recherche exhaustive** de tous les fichiers contenant: "$keywords"
2. **Analyse des dépendances** entre composants
3. **Identification des risques** liés à: "$riskFactors"
4. **Validation de l'impact** sur les fichiers critiques: "$criticalFiles"

INSTRUCTIONS OBLIGATOIRES:
1. Utiliser les outils Grep et Glob pour rechercher TOUS les fichiers
2. Analyser chaque fichier trouvé pour comprendre son rôle
3. Identifier les dépendances entre fichiers
4. Évaluer le risque de modification (1-10)
5. Proposer une stratégie de refactoring sécurisée

LIVRABLES ATTENDUS:
```json
{
  "domain": "$($Domain.Name)",
  "analysis_metadata": {
    "files_analyzed": 0,
    "total_references": 0,
    "risk_score": 0,
    "complexity_level": "LOW|MEDIUM|HIGH|CRITICAL"
  },
  "critical_findings": [
    {
      "file_path": "chemin/du/fichier",
      "references_count": 0,
      "risk_level": "LOW|MEDIUM|HIGH|CRITICAL",
      "dependencies": ["fichier1", "fichier2"],
      "recommended_action": "MODIFY|REFACTOR|REPLACE|PRESERVE"
    }
  ],
  "refactoring_strategy": {
    "phase_1": "Description de la première phase",
    "phase_2": "Description de la deuxième phase",
    "rollback_plan": "Plan de rollback en cas d'échec"
  },
  "risk_mitigation": [
    "Action 1 pour réduire les risques",
    "Action 2 pour réduire les risques"
  ]
}
```

COMMENCER L'ANALYSE MAINTENANT.
"@
}

function Start-UniversalParallelAnalysis {
    param([hashtable]$SystemConfig, [string]$ProjectPath, [string]$ClaudeModel, [int]$MaxSessions, [int]$TimeoutMinutes)

    $jobs = @()
    $sessionResults = @()
    $domains = $SystemConfig.Domains

    Write-Log "🚀 Lancement de l'analyse parallèle pour '$($SystemConfig.Name)'"
    Write-Log "📊 $($domains.Count) domaines à analyser en parallèle"

    # Créer répertoire de résultats
    $resultsPath = Split-Path -Parent $MyInvocation.MyCommand.Path
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"

    foreach ($domain in $domains) {
        $sessionId = [System.Guid]::NewGuid().ToString()
        $resultFile = Join-Path $resultsPath "analysis-result-$($domain.Name).json"

        $prompt = Generate-DomainAnalysisPrompt -Domain $domain -SystemConfig $SystemConfig -ProjectPath $ProjectPath

        Write-Log "🔄 Lancement session: $($domain.Name)"

        $job = Start-Job -ScriptBlock {
            param($SessionId, $ClaudeModel, $TimeoutMinutes, $ProjectPath, $Prompt, $ResultFile)

            try {
                # Exécuter Claude Code CLI
                $claudeArgs = @(
                    "--session-id", $SessionId
                    "--model", $ClaudeModel
                    "--print"
                    "--output-format", "json"
                )

                $result = & claude @claudeArgs $Prompt 2>&1
                $exitCode = $LASTEXITCODE

                if ($exitCode -eq 0) {
                    # Sauvegarder le résultat
                    $result | Out-File -FilePath $ResultFile -Encoding UTF8
                    return @{ Success = $true; SessionId = $SessionId; ResultFile = $ResultFile }
                } else {
                    return @{ Success = $false; SessionId = $SessionId; Error = "Claude CLI failed with exit code $exitCode" }
                }
            } catch {
                return @{ Success = $false; SessionId = $SessionId; Error = $_.Exception.Message }
            }
        } -ArgumentList $sessionId, $ClaudeModel, $TimeoutMinutes, $ProjectPath, $prompt, $resultFile

        $jobs += @{ Job = $job; Domain = $domain.Name; ResultFile = $resultFile; SessionId = $sessionId }

        # Limiter la concurrence
        if ($jobs.Count -ge $MaxSessions) {
            Write-Log "⏳ Attente de sessions disponibles..."
            Wait-Job -Job ($jobs | ForEach-Object { $_.Job }) -Any | Out-Null
        }
    }

    # Attendre tous les jobs
    Write-Log "⏳ Attente de completion de toutes les sessions..."
    $allJobs = $jobs | ForEach-Object { $_.Job }
    Wait-Job -Job $allJobs | Out-Null

    # Collecter les résultats
    foreach ($jobInfo in $jobs) {
        $jobResult = Receive-Job -Job $jobInfo.Job
        Remove-Job -Job $jobInfo.Job

        if ($jobResult.Success) {
            Write-Log "✅ Domaine '$($jobInfo.Domain)' : Analyse terminée"
            $sessionResults += @{
                Domain = $jobInfo.Domain
                Success = $true
                ResultFile = $jobInfo.ResultFile
                SessionId = $jobInfo.SessionId
            }
        } else {
            Write-Log "❌ Domaine '$($jobInfo.Domain)' : $($jobResult.Error)" "ERROR"
            $sessionResults += @{
                Domain = $jobInfo.Domain
                Success = $false
                Error = $jobResult.Error
                SessionId = $jobInfo.SessionId
            }
        }
    }

    return $sessionResults
}

function Consolidate-UniversalResults {
    param([array]$SessionResults, [hashtable]$SystemConfig)

    $consolidatedResult = @{
        system_name = $SystemConfig.Name
        analysis_metadata = @{
            timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            total_domains = $SessionResults.Count
            completed_domains = ($SessionResults | Where-Object { $_.Success }).Count
            failed_domains = ($SessionResults | Where-Object { -not $_.Success }).Count
            overall_success_rate = 0
        }
        domain_analyses = @()
        cross_domain_dependencies = @()
        consolidated_findings = @{
            critical_files = @()
            high_risk_areas = @()
            breaking_changes = @()
            refactoring_phases = @()
        }
        recommendations = @()
    }

    # Calculer le taux de succès
    if ($SessionResults.Count -gt 0) {
        $consolidatedResult.analysis_metadata.overall_success_rate =
            [math]::Round((($SessionResults | Where-Object { $_.Success }).Count / $SessionResults.Count) * 100, 2)
    }

    # Traiter chaque résultat de domaine
    foreach ($result in $SessionResults) {
        if ($result.Success -and (Test-Path $result.ResultFile)) {
            try {
                $domainData = Get-Content -Path $result.ResultFile -Raw | ConvertFrom-Json
                $consolidatedResult.domain_analyses += $domainData
            } catch {
                Write-Log "⚠️ Erreur lors du parsing du résultat pour '$($result.Domain)'" "WARNING"
            }
        }
    }

    # Sauvegarder le résultat consolidé
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $systemName = $SystemConfig.Name -replace ' ', '-' -replace '[^a-zA-Z0-9-]', ''
    $consolidatedFile = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) "COMPLETE-SYSTEM-IMPACT-ANALYSIS-$systemName-$timestamp.json"

    $consolidatedJson = $consolidatedResult | ConvertTo-Json -Depth 10
    Set-Content -Path $consolidatedFile -Value $consolidatedJson -Encoding UTF8

    Write-Log "📊 Résultat consolidé sauvegardé: $consolidatedFile"
    return $consolidatedFile
}

# ===============================
# EXÉCUTION PRINCIPALE
# ===============================

Write-Log "🎯 UNIVERSAL SYSTEM ANALYSIS - DÉMARRAGE"
Write-Log "Système cible: $TargetSystem"

# Gestion du mode création de template
if ($CreateTemplate) {
    $templatePath = Create-ConfigTemplate -SystemName $TargetSystem
    exit 0
}

# Charger la configuration du système
$systemConfig = Load-SystemConfiguration -SystemName $TargetSystem -ConfigFile $ConfigFile

if ($null -eq $systemConfig) {
    Write-Log "❌ Impossible de charger la configuration du système" "ERROR"
    Write-Log "💡 Utilisez -CreateTemplate pour créer un template de configuration" "INFO"
    exit 1
}

# Vérifier Claude Code CLI
try {
    $claudeVersion = claude --version 2>$null
    if ($LASTEXITCODE -ne 0) { throw "Claude CLI non disponible" }
    Write-Log "✅ Claude Code CLI disponible: $claudeVersion"
} catch {
    Write-Log "❌ Claude Code CLI non disponible ou non dans PATH" "ERROR"
    exit 1
}

# Lancer l'analyse parallèle
$sessionResults = Start-UniversalParallelAnalysis -SystemConfig $systemConfig -ProjectPath $ProjectPath -ClaudeModel $ClaudeModel -MaxSessions $MaxConcurrentSessions -TimeoutMinutes $TimeoutMinutes

# Consolider les résultats
$consolidatedResultFile = Consolidate-UniversalResults -SessionResults $sessionResults -SystemConfig $systemConfig

Write-Log "🎉 ANALYSE UNIVERSELLE TERMINÉE"
Write-Log "📁 Résultat final: $consolidatedResultFile"
Write-Log "📊 Taux de succès: $($sessionResults | Where-Object { $_.Success } | Measure-Object | Select-Object -ExpandProperty Count)/$($sessionResults.Count) domaines"