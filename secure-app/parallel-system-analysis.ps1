# 🚀 PARALLEL SYSTEM ANALYSIS - SOLUTION B EXPERT
# Revolutionary Control Center - Exhaustive Impact Analysis
# Author: Expert PowerShell + Claude Code CLI Integration

param(
    [string]$ProjectPath = "C:\Users\XmicordiX\Desktop\claude united\revolutionary-control-center",
    [int]$MaxConcurrentSessions = 5,
    [int]$TimeoutMinutes = 10,
    [string]$ClaudeModel = "sonnet"
)

# 🎯 CONFIGURATION DOMAINES D'ANALYSE
$analysisConfig = @{
    "sessions" = @{
        Name = "Sessions"
        Description = "Session management hooks, services, and components"
        SearchPaths = @("src/renderer/hooks", "src/main/services", "src/renderer/services")
        SearchPatterns = @("*session*", "*Session*", "useUnified*", "SessionManager*", "SessionBridge*")
        Priority = 1
        EstimatedComplexity = "HIGH"
    }
    "sqlite" = @{
        Name = "SQLite-Database"
        Description = "SQLite database operations and persistence"
        SearchPaths = @("src/main/services", "src/renderer/services")
        SearchPatterns = @("*sqlite*", "*SQLite*", "*database*", "*Database*", "*persistence*", "*Persistence*")
        Priority = 1
        EstimatedComplexity = "HIGH"
    }
    "ui-ide" = @{
        Name = "UI-IDE-Components"
        Description = "IDE layout, panels, and UI components"
        SearchPaths = @("src/renderer/components/ide", "src/renderer/components/layout", "src/renderer/components/panels")
        SearchPatterns = @("*.tsx", "*.ts")
        Priority = 2
        EstimatedComplexity = "MEDIUM"
    }
    "claude-cli" = @{
        Name = "Claude-CLI-Integration"
        Description = "Claude CLI manager and integration services"
        SearchPaths = @("src/main/services", "src/renderer/components/chat")
        SearchPatterns = @("*claude-cli*", "*ClaudeCli*", "*claude*manager*", "*chat*")
        Priority = 1
        EstimatedComplexity = "HIGH"
    }
    "projects" = @{
        Name = "Project-Management"
        Description = "Project service and related components"
        SearchPaths = @("src/main/services", "src/renderer/components/project")
        SearchPatterns = @("*project*", "*Project*")
        Priority = 2
        EstimatedComplexity = "MEDIUM"
    }
    "preload-ipc" = @{
        Name = "Preload-IPC-Handlers"
        Description = "Preload scripts and IPC communication"
        SearchPaths = @("src/preload", "src/main")
        SearchPatterns = @("preload*", "*ipc*", "*IPC*", "index.ts")
        Priority = 1
        EstimatedComplexity = "CRITICAL"
    }
}

# 🛠️ FONCTIONS UTILITAIRES
function Write-Status {
    param([string]$Message, [string]$Color = "White")
    $timestamp = Get-Date -Format "HH:mm:ss"
    Write-Host "[$timestamp] $Message" -ForegroundColor $Color
}

function Get-FilesInDomain {
    param($Domain, $ProjectPath)

    $allFiles = @()

    foreach ($searchPath in $Domain.SearchPaths) {
        $fullPath = Join-Path $ProjectPath $searchPath

        if (Test-Path $fullPath) {
            foreach ($pattern in $Domain.SearchPatterns) {
                $files = Get-ChildItem -Path $fullPath -Filter $pattern -Recurse -File |
                         Where-Object { $_.Extension -in @('.ts', '.tsx', '.js', '.jsx') }
                $allFiles += $files
            }
        }
    }

    return $allFiles | Sort-Object FullName | Get-Unique
}

function Create-AnalysisPrompt {
    param($Domain, $Files, $ProjectPath)

    $fileList = $Files | ForEach-Object {
        $relativePath = $_.FullName -replace [regex]::Escape($ProjectPath), ""
        $relativePath -replace "^\\", ""
    }

    $prompt = @"
🎯 MISSION: EXHAUSTIVE IMPACT ANALYSIS - DOMAIN: $($Domain.Name)

CONTEXT: Revolutionary Control Center session migration impact analysis
DOMAIN: $($Domain.Name) - $($Domain.Description)
PRIORITY: $($Domain.Priority) | COMPLEXITY: $($Domain.EstimatedComplexity)

FILES TO ANALYZE ($($fileList.Count) files):
$($fileList -join "`n")

ANALYSIS REQUIREMENTS:
1. 📁 FILE SCANNING:
   - Read and analyze EVERY file in the list
   - Extract ALL session-related references
   - Map import/export dependencies
   - Identify critical functions and classes

2. 🔗 DEPENDENCY MAPPING:
   - Find dependencies TO other domains
   - Find dependencies FROM other domains
   - Identify circular dependencies
   - Map data flow patterns

3. 📊 IMPACT ASSESSMENT:
   - Risk level per file (1-10 scale)
   - Breaking changes probability
   - Migration complexity score
   - Critical path identification

4. 🚨 CRITICAL FINDINGS:
   - Session state management patterns
   - Database transaction dependencies
   - UI component session bindings
   - IPC communication patterns

OUTPUT FORMAT (STRICT JSON):
{
  "domain": "$($Domain.Name)",
  "analysis_timestamp": "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')",
  "files_analyzed": {
    "total_count": 0,
    "files": [
      {
        "path": "relative/path/to/file.ts",
        "session_references": ["ref1", "ref2"],
        "imports": ["import1", "import2"],
        "exports": ["export1", "export2"],
        "risk_score": 0,
        "critical_functions": ["func1", "func2"]
      }
    ]
  },
  "domain_dependencies": {
    "depends_on": ["domain1", "domain2"],
    "used_by": ["domain3", "domain4"],
    "circular_deps": ["domain5"]
  },
  "impact_assessment": {
    "overall_risk_score": 0,
    "migration_complexity": "LOW|MEDIUM|HIGH|CRITICAL",
    "breaking_changes_probability": 0,
    "critical_paths": ["path1", "path2"]
  },
  "critical_findings": [
    {
      "type": "SESSION_STATE|DATABASE|UI_BINDING|IPC",
      "description": "detailed finding",
      "affected_files": ["file1", "file2"],
      "severity": "LOW|MEDIUM|HIGH|CRITICAL"
    }
  ],
  "recommendations": [
    "specific recommendation 1",
    "specific recommendation 2"
  ]
}

⚠️ CRITICAL: Respond ONLY with valid JSON. No explanatory text before or after.
"@

    return $prompt
}

function Start-DomainAnalysisSession {
    param($Domain, $Files, $ProjectPath, $SessionId, $ClaudeModel, $TimeoutMinutes)

    Write-Status "🚀 Starting analysis session for $($Domain.Name)" "Green"

    # Créer prompt d'analyse
    $prompt = Create-AnalysisPrompt -Domain $Domain -Files $Files -ProjectPath $ProjectPath

    # Sauvegarder prompt pour debug
    $promptFile = "analysis-prompt-$($Domain.Name.ToLower()).txt"
    $prompt | Out-File -FilePath $promptFile -Encoding UTF8

    # Créer script PowerShell pour session Claude dédiée
    $sessionScript = @"
`$ErrorActionPreference = 'Stop'
`$sessionId = '$SessionId'
`$domain = '$($Domain.Name)'
`$startTime = Get-Date

Write-Host "🎯 [`$sessionId] Starting analysis for `$domain..." -ForegroundColor Cyan

try {
    # Lire le prompt depuis le fichier
    `$promptContent = Get-Content '$promptFile' -Raw

    # Exécuter Claude avec session dédiée
    `$result = claude --model $ClaudeModel --session-id `$sessionId --output-format json `$promptContent

    `$endTime = Get-Date
    `$duration = (`$endTime - `$startTime).TotalMinutes

    Write-Host "✅ [`$sessionId] Analysis completed in `$([math]::Round(`$duration, 2)) minutes" -ForegroundColor Green

    # Sauvegarder résultat
    `$outputFile = "analysis-result-`$(`$domain.ToLower()).json"
    `$result | Out-File -FilePath `$outputFile -Encoding UTF8

    Write-Host "💾 [`$sessionId] Results saved to `$outputFile" -ForegroundColor Blue

    # Retourner info de succès
    return @{
        SessionId = `$sessionId
        Domain = `$domain
        Status = "SUCCESS"
        Duration = `$duration
        OutputFile = `$outputFile
        Result = `$result
    }

} catch {
    `$endTime = Get-Date
    `$duration = (`$endTime - `$startTime).TotalMinutes

    Write-Host "❌ [`$sessionId] Analysis failed after `$([math]::Round(`$duration, 2)) minutes" -ForegroundColor Red
    Write-Host "Error: `$(`$_.Exception.Message)" -ForegroundColor Red

    return @{
        SessionId = `$sessionId
        Domain = `$domain
        Status = "FAILED"
        Duration = `$duration
        Error = `$_.Exception.Message
    }
}
"@

    # Sauvegarder script de session
    $sessionScriptFile = "session-script-$($Domain.Name.ToLower()).ps1"
    $sessionScript | Out-File -FilePath $sessionScriptFile -Encoding UTF8

    # Lancer PowerShell session en arrière-plan
    $job = Start-Job -ScriptBlock {
        param($ScriptPath)
        & powershell.exe -File $ScriptPath
    } -ArgumentList (Resolve-Path $sessionScriptFile).Path

    return @{
        Job = $job
        SessionId = $SessionId
        Domain = $Domain.Name
        ScriptFile = $sessionScriptFile
        PromptFile = $promptFile
        StartTime = Get-Date
    }
}

function Wait-ForAnalysisCompletion {
    param($Sessions, $TimeoutMinutes)

    $timeoutTime = (Get-Date).AddMinutes($TimeoutMinutes)
    $completedSessions = @()
    $failedSessions = @()

    Write-Status "⏳ Waiting for $($Sessions.Count) analysis sessions to complete..." "Yellow"
    Write-Status "⏰ Timeout set for $TimeoutMinutes minutes" "Yellow"

    while ($Sessions.Count -gt 0 -and (Get-Date) -lt $timeoutTime) {
        Start-Sleep -Seconds 5

        $stillRunning = @()

        foreach ($session in $Sessions) {
            $job = $session.Job

            if ($job.State -eq "Completed") {
                $result = Receive-Job -Job $job
                Remove-Job -Job $job

                $session.EndTime = Get-Date
                $session.Duration = ($session.EndTime - $session.StartTime).TotalMinutes
                $session.Result = $result

                $completedSessions += $session
                Write-Status "✅ $($session.Domain) analysis completed" "Green"

            } elseif ($job.State -eq "Failed") {
                $error = Receive-Job -Job $job
                Remove-Job -Job $job

                $session.EndTime = Get-Date
                $session.Duration = ($session.EndTime - $session.StartTime).TotalMinutes
                $session.Error = $error

                $failedSessions += $session
                Write-Status "❌ $($session.Domain) analysis failed" "Red"

            } else {
                $stillRunning += $session
                $elapsed = ((Get-Date) - $session.StartTime).TotalMinutes
                Write-Status "⏳ $($session.Domain) still running... ($([math]::Round($elapsed, 1))min elapsed)" "Yellow"
            }
        }

        $Sessions = $stillRunning
    }

    # Gérer les timeouts
    foreach ($session in $Sessions) {
        Stop-Job -Job $session.Job -Force
        Remove-Job -Job $session.Job -Force
        $session.EndTime = Get-Date
        $session.Duration = ($session.EndTime - $session.StartTime).TotalMinutes
        $session.Error = "TIMEOUT after $TimeoutMinutes minutes"
        $failedSessions += $session
        Write-Status "⏰ $($session.Domain) analysis timed out" "Red"
    }

    return @{
        Completed = $completedSessions
        Failed = $failedSessions
        TotalDuration = $timeoutMinutes
    }
}

function Consolidate-AnalysisResults {
    param($CompletedSessions, $FailedSessions, $ProjectPath)

    Write-Status "📊 Consolidating analysis results..." "Cyan"

    $consolidatedReport = @{
        analysis_metadata = @{
            project_path = $ProjectPath
            analysis_timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
            total_domains = $analysisConfig.Count
            completed_domains = $CompletedSessions.Count
            failed_domains = $FailedSessions.Count
            overall_success_rate = [math]::Round(($CompletedSessions.Count / $analysisConfig.Count) * 100, 2)
        }
        domain_analyses = @()
        cross_domain_dependencies = @()
        consolidated_findings = @{
            critical_files = @()
            high_risk_areas = @()
            migration_complexity = @()
            breaking_changes = @()
        }
        recommendations = @()
        execution_summary = @{
            completed_sessions = @()
            failed_sessions = @()
        }
    }

    # Traiter sessions complétées
    foreach ($session in $CompletedSessions) {
        try {
            $resultFile = "analysis-result-$($session.Domain.ToLower()).json"
            if (Test-Path $resultFile) {
                $domainAnalysis = Get-Content $resultFile -Raw | ConvertFrom-Json
                $consolidatedReport.domain_analyses += $domainAnalysis

                Write-Status "✅ Consolidated results from $($session.Domain)" "Green"
            }
        } catch {
            Write-Status "⚠️ Failed to parse results from $($session.Domain): $($_.Exception.Message)" "Yellow"
        }

        $consolidatedReport.execution_summary.completed_sessions += @{
            domain = $session.Domain
            duration_minutes = [math]::Round($session.Duration, 2)
            session_id = $session.SessionId
        }
    }

    # Traiter sessions échouées
    foreach ($session in $FailedSessions) {
        $consolidatedReport.execution_summary.failed_sessions += @{
            domain = $session.Domain
            error = $session.Error
            duration_minutes = [math]::Round($session.Duration, 2)
            session_id = $session.SessionId
        }
    }

    # Cross-domain dependency analysis
    Write-Status "🔗 Analyzing cross-domain dependencies..." "Cyan"
    $consolidatedReport.cross_domain_dependencies = Analyze-CrossDomainDependencies -DomainAnalyses $consolidatedReport.domain_analyses

    # Consolidated findings
    Write-Status "🎯 Generating consolidated findings..." "Cyan"
    $consolidatedReport.consolidated_findings = Generate-ConsolidatedFindings -DomainAnalyses $consolidatedReport.domain_analyses

    # Final recommendations
    $consolidatedReport.recommendations = Generate-FinalRecommendations -Report $consolidatedReport

    return $consolidatedReport
}

function Analyze-CrossDomainDependencies {
    param($DomainAnalyses)

    $crossDeps = @()

    foreach ($analysis in $DomainAnalyses) {
        if ($analysis.domain_dependencies) {
            $crossDeps += @{
                source_domain = $analysis.domain
                depends_on = $analysis.domain_dependencies.depends_on
                used_by = $analysis.domain_dependencies.used_by
                circular_deps = $analysis.domain_dependencies.circular_deps
            }
        }
    }

    return $crossDeps
}

function Generate-ConsolidatedFindings {
    param($DomainAnalyses)

    $findings = @{
        critical_files = @()
        high_risk_areas = @()
        migration_complexity = @()
        breaking_changes = @()
    }

    foreach ($analysis in $DomainAnalyses) {
        if ($analysis.files_analyzed -and $analysis.files_analyzed.files) {
            # Fichiers critiques (risk_score >= 8)
            $criticalFiles = $analysis.files_analyzed.files | Where-Object { $_.risk_score -ge 8 }
            $findings.critical_files += $criticalFiles | ForEach-Object {
                @{
                    domain = $analysis.domain
                    file = $_.path
                    risk_score = $_.risk_score
                    critical_functions = $_.critical_functions
                }
            }
        }

        if ($analysis.impact_assessment) {
            # Areas à haut risque
            if ($analysis.impact_assessment.overall_risk_score -ge 7) {
                $findings.high_risk_areas += @{
                    domain = $analysis.domain
                    risk_score = $analysis.impact_assessment.overall_risk_score
                    complexity = $analysis.impact_assessment.migration_complexity
                    breaking_changes_prob = $analysis.impact_assessment.breaking_changes_probability
                }
            }
        }

        if ($analysis.critical_findings) {
            # Breaking changes
            $breakingChanges = $analysis.critical_findings | Where-Object { $_.severity -in @("HIGH", "CRITICAL") }
            $findings.breaking_changes += $breakingChanges | ForEach-Object {
                @{
                    domain = $analysis.domain
                    type = $_.type
                    description = $_.description
                    severity = $_.severity
                    affected_files = $_.affected_files
                }
            }
        }
    }

    return $findings
}

function Generate-FinalRecommendations {
    param($Report)

    $recommendations = @()

    # Recommandations basées sur les findings
    if ($Report.consolidated_findings.critical_files.Count -gt 0) {
        $recommendations += "🚨 PRIORITY 1: Address $($Report.consolidated_findings.critical_files.Count) critical files with risk score ≥ 8"
    }

    if ($Report.consolidated_findings.high_risk_areas.Count -gt 0) {
        $recommendations += "⚠️ PRIORITY 2: Plan detailed migration strategy for $($Report.consolidated_findings.high_risk_areas.Count) high-risk domains"
    }

    if ($Report.consolidated_findings.breaking_changes.Count -gt 0) {
        $recommendations += "💥 PRIORITY 3: Prepare rollback procedures for $($Report.consolidated_findings.breaking_changes.Count) potential breaking changes"
    }

    # Recommandations basées sur le taux de succès
    if ($Report.analysis_metadata.overall_success_rate -lt 100) {
        $recommendations += "🔄 RETRY: Re-analyze failed domains before proceeding with migration"
    }

    if ($Report.analysis_metadata.overall_success_rate -ge 90) {
        $recommendations += "✅ PROCEED: Analysis coverage sufficient for migration planning"
    }

    return $recommendations
}

# 🚀 MAIN EXECUTION FLOW
function Start-ParallelSystemAnalysis {
    Write-Status "🎯 STARTING PARALLEL SYSTEM ANALYSIS" "Magenta"
    Write-Status "📁 Project Path: $ProjectPath" "White"
    Write-Status "🔄 Max Concurrent Sessions: $MaxConcurrentSessions" "White"
    Write-Status "⏰ Timeout: $TimeoutMinutes minutes" "White"
    Write-Status "🤖 Claude Model: $ClaudeModel" "White"

    # Vérifier le projet existe
    if (!(Test-Path $ProjectPath)) {
        Write-Status "❌ Project path does not exist: $ProjectPath" "Red"
        return
    }

    # Nettoyer fichiers temporaires précédents
    Get-ChildItem -Filter "analysis-*" -File | Remove-Item -Force
    Get-ChildItem -Filter "session-script-*" -File | Remove-Item -Force

    Write-Status "🧹 Cleaned up previous analysis files" "Gray"

    # Phase 1: Scanner les fichiers par domaine
    Write-Status "📊 Phase 1: Scanning files by domain..." "Cyan"
    $domainFiles = @{}

    foreach ($domainKey in $analysisConfig.Keys) {
        $domain = $analysisConfig[$domainKey]
        $files = Get-FilesInDomain -Domain $domain -ProjectPath $ProjectPath
        $domainFiles[$domainKey] = $files

        Write-Status "📁 $($domain.Name): Found $($files.Count) files" "White"
    }

    # Phase 2: Lancer analyses en parallèle
    Write-Status "🚀 Phase 2: Starting parallel analysis sessions..." "Cyan"
    $activeSessions = @()
    $sessionCounter = 1

    foreach ($domainKey in $analysisConfig.Keys) {
        $domain = $analysisConfig[$domainKey]
        $files = $domainFiles[$domainKey]

        if ($files.Count -eq 0) {
            Write-Status "⚠️ Skipping $($domain.Name) - no files found" "Yellow"
            continue
        }

        # Attendre si trop de sessions actives
        while ($activeSessions.Count -ge $MaxConcurrentSessions) {
            Start-Sleep -Seconds 2
            $activeSessions = $activeSessions | Where-Object { $_.Job.State -eq "Running" }
        }

        $sessionId = "analysis-session-$sessionCounter"
        $session = Start-DomainAnalysisSession -Domain $domain -Files $files -ProjectPath $ProjectPath -SessionId $sessionId -ClaudeModel $ClaudeModel -TimeoutMinutes $TimeoutMinutes

        $activeSessions += $session
        $sessionCounter++

        Write-Status "🚀 Started session for $($domain.Name) [ID: $sessionId]" "Green"
        Start-Sleep -Seconds 1 # Éviter spam
    }

    # Phase 3: Attendre completion
    Write-Status "⏳ Phase 3: Waiting for analysis completion..." "Cyan"
    $results = Wait-ForAnalysisCompletion -Sessions $activeSessions -TimeoutMinutes $TimeoutMinutes

    # Phase 4: Consolidation
    Write-Status "📊 Phase 4: Consolidating results..." "Cyan"
    $finalReport = Consolidate-AnalysisResults -CompletedSessions $results.Completed -FailedSessions $results.Failed -ProjectPath $ProjectPath

    # Phase 5: Sauvegarde finale
    $finalReportFile = "COMPLETE-SYSTEM-IMPACT-ANALYSIS-$(Get-Date -Format 'yyyyMMdd-HHmmss').json"
    $finalReport | ConvertTo-Json -Depth 10 | Out-File -FilePath $finalReportFile -Encoding UTF8

    Write-Status "💾 Final report saved: $finalReportFile" "Green"

    # Phase 6: Résumé
    Write-Status "📋 ANALYSIS SUMMARY" "Magenta"
    Write-Status "✅ Completed: $($results.Completed.Count)/$($analysisConfig.Count) domains" "Green"
    Write-Status "❌ Failed: $($results.Failed.Count)/$($analysisConfig.Count) domains" "Red"
    Write-Status "📊 Success Rate: $($finalReport.analysis_metadata.overall_success_rate)%" "White"
    Write-Status "💡 Recommendations: $($finalReport.recommendations.Count)" "White"

    if ($finalReport.recommendations.Count -gt 0) {
        Write-Status "🎯 KEY RECOMMENDATIONS:" "Yellow"
        foreach ($rec in $finalReport.recommendations) {
            Write-Status "   $rec" "White"
        }
    }

    Write-Status "🏁 PARALLEL ANALYSIS COMPLETE!" "Magenta"
    return $finalReport
}

# Exécuter l'analyse si script lancé directement
if ($MyInvocation.InvocationName -ne '.') {
    Start-ParallelSystemAnalysis
}