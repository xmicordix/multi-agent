# 🔄 UPDATE MIGRATION PHASES FROM ANALYSIS
# Revolutionary Control Center - Phase Updates Based on Exhaustive Analysis
# Author: Expert System Integration

param(
    [Parameter(Mandatory=$true)]
    [string]$AnalysisFile,

    [string]$PhasesDirectory = "..\",
    [switch]$CreateBackups = $true,
    [switch]$ValidatePhases = $true
)

function Write-Status {
    param([string]$Message, [string]$Color = "White")
    $timestamp = Get-Date -Format "HH:mm:ss"
    Write-Host "[$timestamp] $Message" -ForegroundColor $Color
}

function Load-AnalysisData {
    param([string]$FilePath)

    if (!(Test-Path $FilePath)) {
        throw "Analysis file not found: $FilePath"
    }

    try {
        $content = Get-Content $FilePath -Raw | ConvertFrom-Json
        Write-Status "✅ Loaded analysis data from $FilePath" "Green"
        return $content
    } catch {
        throw "Failed to parse analysis file: $($_.Exception.Message)"
    }
}

function Get-PhaseFiles {
    param([string]$Directory)

    $phaseFiles = Get-ChildItem -Path $Directory -Filter "MIGRATION_PHASE_*.md" | Sort-Object Name
    Write-Status "📁 Found $($phaseFiles.Count) phase files" "Cyan"

    return $phaseFiles
}

function Backup-PhaseFiles {
    param([array]$PhaseFiles)

    $backupDir = "phase-backups-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    New-Item -ItemType Directory -Path $backupDir -Force | Out-Null

    foreach ($file in $PhaseFiles) {
        Copy-Item $file.FullName -Destination $backupDir
    }

    Write-Status "💾 Created backups in $backupDir" "Blue"
    return $backupDir
}

function Analyze-PhaseGaps {
    param($AnalysisData, $PhaseFiles)

    Write-Status "🔍 Analyzing gaps between current phases and analysis findings..." "Yellow"

    $gaps = @{
        missing_critical_files = @()
        missing_domains = @()
        underestimated_complexity = @()
        missing_dependencies = @()
        new_recommendations = @()
    }

    # 1. Fichiers critiques non couverts
    if ($AnalysisData.consolidated_findings.critical_files) {
        $criticalFiles = $AnalysisData.consolidated_findings.critical_files | Where-Object { $_.risk_score -ge 8 }

        foreach ($file in $criticalFiles) {
            $isCovered = $false

            foreach ($phaseFile in $PhaseFiles) {
                $phaseContent = Get-Content $phaseFile.FullName -Raw
                if ($phaseContent -match [regex]::Escape($file.file)) {
                    $isCovered = $true
                    break
                }
            }

            if (!$isCovered) {
                $gaps.missing_critical_files += $file
            }
        }
    }

    # 2. Domaines non couverts
    if ($AnalysisData.domain_analyses) {
        $analyzedDomains = $AnalysisData.domain_analyses | ForEach-Object { $_.domain }

        foreach ($domain in $analyzedDomains) {
            $isDomainCovered = $false

            foreach ($phaseFile in $PhaseFiles) {
                $phaseContent = Get-Content $phaseFile.FullName -Raw
                if ($phaseContent -match $domain -or
                    $phaseContent -match ($domain -replace "-", "") -or
                    $phaseContent -match ($domain -replace "-", " ")) {
                    $isDomainCovered = $true
                    break
                }
            }

            if (!$isDomainCovered) {
                $gaps.missing_domains += $domain
            }
        }
    }

    # 3. Complexité sous-estimée
    if ($AnalysisData.domain_analyses) {
        foreach ($domainAnalysis in $AnalysisData.domain_analyses) {
            if ($domainAnalysis.impact_assessment.overall_risk_score -ge 8) {
                $gaps.underestimated_complexity += @{
                    domain = $domainAnalysis.domain
                    risk_score = $domainAnalysis.impact_assessment.overall_risk_score
                    complexity = $domainAnalysis.impact_assessment.migration_complexity
                }
            }
        }
    }

    # 4. Dépendances croisées manquantes
    if ($AnalysisData.cross_domain_dependencies) {
        foreach ($crossDep in $AnalysisData.cross_domain_dependencies) {
            if ($crossDep.circular_deps -and $crossDep.circular_deps.Count -gt 0) {
                $gaps.missing_dependencies += $crossDep
            }
        }
    }

    # 5. Nouvelles recommandations
    if ($AnalysisData.recommendations) {
        $gaps.new_recommendations = $AnalysisData.recommendations
    }

    Write-Status "📊 Gap analysis completed:" "Cyan"
    Write-Status "   - Missing critical files: $($gaps.missing_critical_files.Count)" "White"
    Write-Status "   - Missing domains: $($gaps.missing_domains.Count)" "White"
    Write-Status "   - Underestimated complexity: $($gaps.underestimated_complexity.Count)" "White"
    Write-Status "   - Missing dependencies: $($gaps.missing_dependencies.Count)" "White"
    Write-Status "   - New recommendations: $($gaps.new_recommendations.Count)" "White"

    return $gaps
}

function Generate-PhaseUpdates {
    param($Gaps, $AnalysisData)

    Write-Status "🔄 Generating phase updates based on analysis..." "Yellow"

    $updates = @{}

    # PHASE 1 Updates
    $phase1Updates = @()
    if ($Gaps.missing_critical_files.Count -gt 0) {
        $phase1Updates += "## 🚨 ADDITIONAL CRITICAL FILES IDENTIFIED"
        $phase1Updates += ""
        $phase1Updates += "Based on exhaustive analysis, the following critical files must be addressed:"
        $phase1Updates += ""

        foreach ($file in $Gaps.missing_critical_files) {
            $phase1Updates += "### $($file.file) (Risk Score: $($file.risk_score)/10)"
            $phase1Updates += "- **Domain**: $($file.domain)"
            $phase1Updates += "- **Critical Functions**: $($file.critical_functions -join ', ')"
            $phase1Updates += "- **Required Action**: Include in UnifiedSessionFacade integration"
            $phase1Updates += ""
        }
    }

    # PHASE 5 Updates (Cleanup)
    $phase5Updates = @()
    if ($Gaps.missing_domains.Count -gt 0) {
        $phase5Updates += "## 🧹 ADDITIONAL DOMAINS TO CLEANUP"
        $phase5Updates += ""
        $phase5Updates += "Analysis revealed additional domains requiring cleanup:"
        $phase5Updates += ""

        foreach ($domain in $Gaps.missing_domains) {
            $domainAnalysis = $AnalysisData.domain_analyses | Where-Object { $_.domain -eq $domain }
            if ($domainAnalysis) {
                $phase5Updates += "### $domain Domain"
                $phase5Updates += "- **Files**: $($domainAnalysis.files_analyzed.total_count) files"
                $phase5Updates += "- **Risk Score**: $($domainAnalysis.impact_assessment.overall_risk_score)/10"
                $phase5Updates += "- **Cleanup Priority**: $(if ($domainAnalysis.impact_assessment.overall_risk_score -ge 7) { 'HIGH' } else { 'MEDIUM' })"
                $phase5Updates += ""
            }
        }
    }

    # PHASE 6 Updates (Core System)
    $phase6Updates = @()
    if ($Gaps.underestimated_complexity.Count -gt 0) {
        $phase6Updates += "## ⚠️ COMPLEXITY ADJUSTMENTS"
        $phase6Updates += ""
        $phase6Updates += "Analysis revealed higher complexity than initially estimated:"
        $phase6Updates += ""

        foreach ($complex in $Gaps.underestimated_complexity) {
            $phase6Updates += "### $($complex.domain) Domain"
            $phase6Updates += "- **Risk Score**: $($complex.risk_score)/10"
            $phase6Updates += "- **Complexity**: $($complex.complexity)"
            $phase6Updates += "- **Required Action**: Extended testing and validation"
            $phase6Updates += ""
        }
    }

    # NEW PHASE 8 - Post-Analysis Validation
    $phase8Updates = @()
    if ($Gaps.missing_dependencies.Count -gt 0) {
        $phase8Updates += "# 🔗 PHASE 8 : POST-ANALYSIS VALIDATION - CIRCULAR DEPENDENCIES"
        $phase8Updates += ""
        $phase8Updates += "## 📊 VUE D'ENSEMBLE"
        $phase8Updates += ""
        $phase8Updates += "**Objectif** : Résoudre les dépendances circulaires détectées lors de l'analyse exhaustive."
        $phase8Updates += ""
        $phase8Updates += "**Durée Estimée** : 3-5 jours"
        $phase8Updates += "**Niveau de Risque** : 🟡 MEDIUM"
        $phase8Updates += "**Prérequis** : Phases 1-7 complétées"
        $phase8Updates += ""
        $phase8Updates += "## 🔄 DÉPENDANCES CIRCULAIRES DÉTECTÉES"
        $phase8Updates += ""

        foreach ($dep in $Gaps.missing_dependencies) {
            $phase8Updates += "### $($dep.source_domain) ↔ $($dep.circular_deps -join ' ↔ ')"
            $phase8Updates += "- **Source**: $($dep.source_domain)"
            $phase8Updates += "- **Circular Dependencies**: $($dep.circular_deps -join ', ')"
            $phase8Updates += "- **Resolution Strategy**: Dependency injection pattern"
            $phase8Updates += ""
        }
    }

    $updates = @{
        "MIGRATION_PHASE_1_ARCHITECTURE_BRIDGE.md" = $phase1Updates
        "MIGRATION_PHASE_5_AUTOMATED_CLEANUP.md" = $phase5Updates
        "MIGRATION_PHASE_6_CORE_SYSTEM_INTEGRATION.md" = $phase6Updates
        "MIGRATION_PHASE_8_POST_ANALYSIS_VALIDATION.md" = $phase8Updates
    }

    return $updates
}

function Apply-PhaseUpdates {
    param($Updates, $PhasesDirectory)

    Write-Status "📝 Applying updates to phase files..." "Green"

    foreach ($phaseFile in $Updates.Keys) {
        $fullPath = Join-Path $PhasesDirectory $phaseFile
        $updateContent = $Updates[$phaseFile]

        if ($updateContent.Count -gt 0) {
            if ($phaseFile -eq "MIGRATION_PHASE_8_POST_ANALYSIS_VALIDATION.md") {
                # Créer nouvelle phase
                $updateContent | Out-File -FilePath $fullPath -Encoding UTF8
                Write-Status "✨ Created new phase: $phaseFile" "Green"
            } else {
                # Mettre à jour phase existante
                if (Test-Path $fullPath) {
                    $existingContent = Get-Content $fullPath -Raw
                    $newContent = $existingContent + "`n`n---`n`n" + ($updateContent -join "`n")
                    $newContent | Out-File -FilePath $fullPath -Encoding UTF8
                    Write-Status "📝 Updated existing phase: $phaseFile" "Green"
                } else {
                    Write-Status "⚠️ Phase file not found: $phaseFile" "Yellow"
                }
            }
        }
    }
}

function Generate-ExecutionPlan {
    param($AnalysisData, $PhasesDirectory)

    Write-Status "📋 Generating execution plan based on analysis..." "Cyan"

    $executionPlan = @"
# 🚀 EXECUTION PLAN - GENERATED FROM ANALYSIS
# Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
# Based on: $AnalysisFile

## 📊 ANALYSIS SUMMARY
- **Domains Analyzed**: $($AnalysisData.analysis_metadata.total_domains)
- **Success Rate**: $($AnalysisData.analysis_metadata.overall_success_rate)%
- **Critical Files**: $($AnalysisData.consolidated_findings.critical_files.Count)
- **High Risk Areas**: $($AnalysisData.consolidated_findings.high_risk_areas.Count)

## 🎯 EXECUTION COMMANDS

### Phase 1: Architecture Bridge
``````bash
claude --session-id phase-1 --context-file "$AnalysisFile" --execute-plan "MIGRATION_PHASE_1_ARCHITECTURE_BRIDGE.md"
``````

### Phase 2: Progressive Migration
``````bash
claude --session-id phase-2 --context-file "$AnalysisFile" --execute-plan "MIGRATION_PHASE_2_PROGRESSIVE_MIGRATION.md"
``````

### Phase 3: Continuous Validation
``````bash
claude --session-id phase-3 --context-file "$AnalysisFile" --execute-plan "MIGRATION_PHASE_3_CONTINUOUS_VALIDATION.md"
``````

### Phase 4: Rollback System
``````bash
claude --session-id phase-4 --context-file "$AnalysisFile" --execute-plan "MIGRATION_PHASE_4_ROLLBACK_SYSTEM.md"
``````

### Phase 5: Automated Cleanup
``````bash
claude --session-id phase-5 --context-file "$AnalysisFile" --execute-plan "MIGRATION_PHASE_5_AUTOMATED_CLEANUP.md"
``````

### Phase 6: Core System Integration
``````bash
claude --session-id phase-6 --context-file "$AnalysisFile" --execute-plan "MIGRATION_PHASE_6_CORE_SYSTEM_INTEGRATION.md"
``````

### Phase 7: Final Validation
``````bash
claude --session-id phase-7 --context-file "$AnalysisFile" --execute-plan "MIGRATION_PHASE_7_FINAL_VALIDATION.md"
``````

### Phase 8: Post-Analysis Validation (if created)
``````bash
claude --session-id phase-8 --context-file "$AnalysisFile" --execute-plan "MIGRATION_PHASE_8_POST_ANALYSIS_VALIDATION.md"
``````

## 🔄 PARALLEL EXECUTION (ADVANCED)
``````bash
# Lancer phases indépendantes en parallèle
Start-Job { claude --session-id phase-1 --context-file "$AnalysisFile" --execute-plan "MIGRATION_PHASE_1_ARCHITECTURE_BRIDGE.md" }
Start-Job { claude --session-id phase-5 --context-file "$AnalysisFile" --execute-plan "MIGRATION_PHASE_5_AUTOMATED_CLEANUP.md" }
``````

## 📋 RECOMMENDATIONS FROM ANALYSIS
$($AnalysisData.recommendations | ForEach-Object { "- $_" } | Out-String)

## 🚨 CRITICAL AREAS REQUIRING ATTENTION
$($AnalysisData.consolidated_findings.critical_files | ForEach-Object {
    "- **$($_.file)** (Risk: $($_.risk_score)/10) - Domain: $($_.domain)"
} | Out-String)
"@

    $executionPlanFile = Join-Path $PhasesDirectory "EXECUTION_PLAN_FROM_ANALYSIS.md"
    $executionPlan | Out-File -FilePath $executionPlanFile -Encoding UTF8

    Write-Status "📋 Execution plan saved: $executionPlanFile" "Green"
    return $executionPlanFile
}

function Validate-UpdatedPhases {
    param($PhasesDirectory)

    Write-Status "✅ Validating updated phases..." "Yellow"

    $phaseFiles = Get-ChildItem -Path $PhasesDirectory -Filter "MIGRATION_PHASE_*.md"
    $validationResults = @()

    foreach ($phaseFile in $phaseFiles) {
        $content = Get-Content $phaseFile.FullName -Raw

        $validation = @{
            file = $phaseFile.Name
            has_objectives = $content -match "OBJECTIF"
            has_steps = $content -match "ÉTAPE"
            has_validation = $content -match "VALIDATION"
            has_code_examples = $content -match "```"
            word_count = ($content -split '\s+').Count
        }

        $validationResults += $validation
    }

    Write-Status "📊 Phase validation results:" "Cyan"
    foreach ($result in $validationResults) {
        $status = if ($result.has_objectives -and $result.has_steps -and $result.has_validation) { "✅" } else { "⚠️" }
        Write-Status "   $status $($result.file) - $($result.word_count) words" "White"
    }

    return $validationResults
}

# 🚀 MAIN EXECUTION
function Start-PhaseUpdate {
    Write-Status "🔄 STARTING PHASE UPDATE FROM ANALYSIS" "Magenta"

    try {
        # 1. Charger données d'analyse
        $analysisData = Load-AnalysisData -FilePath $AnalysisFile

        # 2. Obtenir fichiers phases
        $phaseFiles = Get-PhaseFiles -Directory $PhasesDirectory

        # 3. Backup si demandé
        if ($CreateBackups) {
            $backupDir = Backup-PhaseFiles -PhaseFiles $phaseFiles
        }

        # 4. Analyser les gaps
        $gaps = Analyze-PhaseGaps -AnalysisData $analysisData -PhaseFiles $phaseFiles

        # 5. Générer les mises à jour
        $updates = Generate-PhaseUpdates -Gaps $gaps -AnalysisData $analysisData

        # 6. Appliquer les mises à jour
        Apply-PhaseUpdates -Updates $updates -PhasesDirectory $PhasesDirectory

        # 7. Générer plan d'exécution
        $executionPlan = Generate-ExecutionPlan -AnalysisData $analysisData -PhasesDirectory $PhasesDirectory

        # 8. Valider si demandé
        if ($ValidatePhases) {
            $validation = Validate-UpdatedPhases -PhasesDirectory $PhasesDirectory
        }

        Write-Status "🏁 PHASE UPDATE COMPLETED SUCCESSFULLY!" "Green"
        Write-Status "📋 Execution plan: $executionPlan" "Cyan"

        if ($CreateBackups) {
            Write-Status "💾 Backups created in: $backupDir" "Blue"
        }

    } catch {
        Write-Status "❌ Error during phase update: $($_.Exception.Message)" "Red"
        throw
    }
}

# Exécuter si lancé directement
if ($MyInvocation.InvocationName -ne '.') {
    Start-PhaseUpdate
}