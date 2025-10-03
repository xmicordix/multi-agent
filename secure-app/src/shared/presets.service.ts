// 🎯 Advanced Presets Service - Professional Architecture
// Integration of sophisticated patterns from original GUI system

export interface DomainConfig {
  name: string;
  keywords: string[];
}

export interface AdvancedPreset {
  name: string;
  description: string;
  domains: DomainConfig[];
  critical_files: string[];
  risk_factors: string[];
  complexity: 'LOW' | 'MEDIUM' | 'HIGH' | 'CRITICAL';
  priority: number;
  estimated_effort_days: string;
}

export interface AnalysisMode {
  id: string;
  name: string;
  description: string;
  stop_on_error?: boolean;
  dry_run?: boolean;
}

export interface PhaseExecution {
  migration_phases: string[];
  implementation_phases: string[];
}

export interface AdvancedAnalysisConfig {
  presets: Record<string, AdvancedPreset>;
  execution: {
    parallel_sessions: {
      min: number;
      max: number;
      default: number;
    };
    analysis_modes: AnalysisMode[];
    phases: PhaseExecution;
  };
}

export class AdvancedPresetsService {
  private config: AdvancedAnalysisConfig | null = null;

  constructor(private configService: any) {}

  /**
   * Load advanced presets configuration from main config
   */
  async loadPresetsConfig(): Promise<AdvancedAnalysisConfig> {
    try {
      const mainConfig = await this.configService.loadConfig();

      if (!mainConfig.analysis?.presets) {
        throw new Error('No advanced presets found in configuration');
      }

      this.config = mainConfig.analysis;
      return this.config;
    } catch (error) {
      console.error('Failed to load presets config:', error);
      throw error;
    }
  }

  /**
   * Get all available preset names
   */
  getPresetNames(): string[] {
    if (!this.config) {
      throw new Error('Presets not loaded. Call loadPresetsConfig() first.');
    }

    return Object.keys(this.config.presets);
  }

  /**
   * Get specific preset configuration
   */
  getPreset(presetName: string): AdvancedPreset {
    if (!this.config) {
      throw new Error('Presets not loaded. Call loadPresetsConfig() first.');
    }

    const preset = this.config.presets[presetName];
    if (!preset) {
      throw new Error(`Preset '${presetName}' not found`);
    }

    return preset;
  }

  /**
   * Get presets sorted by priority
   */
  getPresetsByPriority(): Array<{ name: string; preset: AdvancedPreset }> {
    if (!this.config) {
      throw new Error('Presets not loaded. Call loadPresetsConfig() first.');
    }

    return Object.entries(this.config.presets)
      .map(([name, preset]) => ({ name, preset }))
      .sort((a, b) => a.preset.priority - b.preset.priority);
  }

  /**
   * Get presets by complexity level
   */
  getPresetsByComplexity(complexity: 'LOW' | 'MEDIUM' | 'HIGH' | 'CRITICAL'): Array<{ name: string; preset: AdvancedPreset }> {
    if (!this.config) {
      throw new Error('Presets not loaded. Call loadPresetsConfig() first.');
    }

    return Object.entries(this.config.presets)
      .filter(([_, preset]) => preset.complexity === complexity)
      .map(([name, preset]) => ({ name, preset }));
  }

  /**
   * Generate analysis request from preset
   */
  generateAnalysisRequest(presetName: string, options: {
    maxSessions?: number;
    timeoutMinutes?: number;
    dryRun?: boolean;
    mode?: string;
  } = {}): any {
    const preset = this.getPreset(presetName);

    return {
      systemName: presetName,
      config: JSON.stringify(preset, null, 2),
      maxSessions: options.maxSessions || this.config!.execution.parallel_sessions.default,
      timeoutMinutes: options.timeoutMinutes || 10,
      dryRun: options.dryRun || false,
      analysisMode: options.mode || 'safe'
    };
  }

  /**
   * Get all available analysis modes
   */
  getAnalysisModes(): AnalysisMode[] {
    if (!this.config) {
      throw new Error('Presets not loaded. Call loadPresetsConfig() first.');
    }

    return this.config.execution.analysis_modes;
  }

  /**
   * Get phase execution configuration
   */
  getPhaseExecution(): PhaseExecution {
    if (!this.config) {
      throw new Error('Presets not loaded. Call loadPresetsConfig() first.');
    }

    return this.config.execution.phases;
  }

  /**
   * Generate comprehensive prompt from preset
   */
  generateAdvancedPrompt(presetName: string): string {
    const preset = this.getPreset(presetName);

    const keywords = preset.domains.map(d => d.keywords).flat().join('", "');
    const criticalFiles = preset.critical_files.join('", "');
    const riskFactors = preset.risk_factors.join('", "');

    return `MISSION CRITIQUE: Analyse exhaustive du système '${preset.name}'

CONTEXTE SYSTÈME:
- Projet: Revolutionary Control Center
- Système cible: ${preset.name}
- Description: ${preset.description}
- Complexité: ${preset.complexity}
- Priorité: ${preset.priority}
- Effort estimé: ${preset.estimated_effort_days} jours

DOMAINES D'ANALYSE:
${preset.domains.map(domain => `
- **${domain.name}**: ${domain.keywords.join(', ')}`).join('')}

MÉTHODOLOGIE D'ANALYSE:
1. **Recherche exhaustive** de tous les fichiers contenant: "${keywords}"
2. **Analyse des dépendances** entre composants
3. **Identification des risques** liés à: "${riskFactors}"
4. **Validation de l'impact** sur les fichiers critiques: "${criticalFiles}"

INSTRUCTIONS OBLIGATOIRES:
1. Utiliser les outils Grep et Glob pour rechercher TOUS les fichiers
2. Analyser chaque fichier trouvé pour comprendre son rôle
3. Identifier les dépendances entre fichiers
4. Évaluer le risque de modification (1-10)
5. Proposer une stratégie de refactoring sécurisée

LIVRABLES ATTENDUS:
\`\`\`json
{
  "system": "${preset.name}",
  "analysis_metadata": {
    "files_analyzed": 0,
    "total_references": 0,
    "risk_score": 0,
    "complexity_level": "${preset.complexity}",
    "estimated_effort": "${preset.estimated_effort_days}"
  },
  "domain_analyses": [
    ${preset.domains.map(domain => `{
      "domain": "${domain.name}",
      "keywords": ["${domain.keywords.join('", "')}"],
      "files_found": [],
      "risk_assessment": "LOW|MEDIUM|HIGH|CRITICAL"
    }`).join(',\n    ')}
  ],
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
\`\`\`

COMMENCER L'ANALYSE MAINTENANT.`;
  }

  /**
   * Validate preset configuration
   */
  validatePreset(preset: AdvancedPreset): { isValid: boolean; errors: string[] } {
    const errors: string[] = [];

    if (!preset.name || preset.name.trim() === '') {
      errors.push('Preset name is required');
    }

    if (!preset.description || preset.description.trim() === '') {
      errors.push('Preset description is required');
    }

    if (!preset.domains || preset.domains.length === 0) {
      errors.push('At least one domain is required');
    }

    preset.domains?.forEach((domain, index) => {
      if (!domain.name || domain.name.trim() === '') {
        errors.push(`Domain ${index + 1}: name is required`);
      }
      if (!domain.keywords || domain.keywords.length === 0) {
        errors.push(`Domain ${index + 1}: at least one keyword is required`);
      }
    });

    if (!preset.critical_files || preset.critical_files.length === 0) {
      errors.push('At least one critical file is required');
    }

    if (!['LOW', 'MEDIUM', 'HIGH', 'CRITICAL'].includes(preset.complexity)) {
      errors.push('Invalid complexity level');
    }

    if (typeof preset.priority !== 'number' || preset.priority < 1 || preset.priority > 10) {
      errors.push('Priority must be a number between 1 and 10');
    }

    return {
      isValid: errors.length === 0,
      errors
    };
  }

  /**
   * Get preset statistics
   */
  getPresetStats(): {
    total: number;
    byComplexity: Record<string, number>;
    byPriority: Record<number, number>;
    totalDomains: number;
    totalKeywords: number;
  } {
    if (!this.config) {
      throw new Error('Presets not loaded. Call loadPresetsConfig() first.');
    }

    const presets = Object.values(this.config.presets);

    const byComplexity = presets.reduce((acc, preset) => {
      acc[preset.complexity] = (acc[preset.complexity] || 0) + 1;
      return acc;
    }, {} as Record<string, number>);

    const byPriority = presets.reduce((acc, preset) => {
      acc[preset.priority] = (acc[preset.priority] || 0) + 1;
      return acc;
    }, {} as Record<number, number>);

    const totalDomains = presets.reduce((sum, preset) => sum + preset.domains.length, 0);
    const totalKeywords = presets.reduce((sum, preset) =>
      sum + preset.domains.reduce((domainSum, domain) => domainSum + domain.keywords.length, 0), 0);

    return {
      total: presets.length,
      byComplexity,
      byPriority,
      totalDomains,
      totalKeywords
    };
  }
}