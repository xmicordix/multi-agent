/**
 * 🚀 CONFIGURATION SERVICE 2025 - Professional Configuration Management
 * Centralized configuration service with type safety and validation
 */

export interface AppConfig {
  name: string;
  version: string;
  description: string;
  server: ServerConfig;
  security: SecurityConfig;
  paths: PathsConfig;
  analysis: AnalysisConfig;
  logging: LoggingConfig;
}

export interface ServerConfig {
  host: string;
  port: number;
  cors: {
    origin: string[];
    credentials: boolean;
  };
}

export interface SecurityConfig {
  maxSessions: {
    min: number;
    max: number;
    default: number;
  };
  timeout: {
    min: number;
    max: number;
    default: number;
    unit: string;
  };
  allowedCommands: string[];
}

export interface PathsConfig {
  scripts: string;
  config: string;
  data: string;
  logs: string;
  temp: string;
}

export interface AnalysisSystemDefinition {
  id: string;
  name: string;
  description: string;
  icon: string;
}

export interface AnalysisConfig {
  systems: AnalysisSystemDefinition[];
}

export interface LoggingConfig {
  level: string;
  file: string;
  maxSize: string;
  maxFiles: number;
}

export interface AnalysisRequest {
  systemName: string;
  config: string;
  maxSessions: number;
  timeoutMinutes: number;
  dryRun: boolean;
}

export interface AnalysisResult {
  success: boolean;
  output?: string;
  error?: string;
  exitCode: number;
  executionTime: number;
}

export class ConfigService {
  private static instance: ConfigService;
  private config: AppConfig | null = null;
  private configPath: string;

  private constructor() {
    this.configPath = './config/app.config.json';
  }

  public static getInstance(): ConfigService {
    if (!ConfigService.instance) {
      ConfigService.instance = new ConfigService();
    }
    return ConfigService.instance;
  }

  public async loadConfig(): Promise<AppConfig> {
    if (this.config) {
      return this.config;
    }

    try {
      const configText = await Deno.readTextFile(this.configPath);
      this.config = JSON.parse(configText) as AppConfig;
      this.validateConfig(this.config);
      console.log(`🔧 Configuration loaded: ${this.config.name} v${this.config.version}`);
      return this.config;
    } catch (error) {
      throw new Error(`Failed to load configuration: ${error.message}`);
    }
  }

  public getConfig(): AppConfig {
    if (!this.config) {
      throw new Error('Configuration not loaded. Call loadConfig() first.');
    }
    return this.config;
  }

  public getServerConfig(): ServerConfig {
    return this.getConfig().server;
  }

  public getSecurityConfig(): SecurityConfig {
    return this.getConfig().security;
  }

  public getPathsConfig(): PathsConfig {
    return this.getConfig().paths;
  }

  public getAnalysisConfig(): AnalysisConfig {
    return this.getConfig().analysis;
  }

  public getAnalysisSystemById(id: string): AnalysisSystemDefinition | undefined {
    return this.getAnalysisConfig().systems.find(system => system.id === id);
  }

  public validateAnalysisRequest(request: AnalysisRequest): void {
    const security = this.getSecurityConfig();

    // Validate system name
    if (!request.systemName || request.systemName.length > 50) {
      throw new Error('Invalid system name');
    }

    if (!/^[a-zA-Z0-9-_]+$/.test(request.systemName)) {
      throw new Error('System name contains invalid characters');
    }

    // Check if system exists in configuration
    const systemDef = this.getAnalysisSystemById(request.systemName);
    if (!systemDef) {
      throw new Error(`Unknown system: ${request.systemName}`);
    }

    // Validate sessions
    if (request.maxSessions < security.maxSessions.min ||
        request.maxSessions > security.maxSessions.max) {
      throw new Error(`Max sessions must be between ${security.maxSessions.min} and ${security.maxSessions.max}`);
    }

    // Validate timeout
    if (request.timeoutMinutes < security.timeout.min ||
        request.timeoutMinutes > security.timeout.max) {
      throw new Error(`Timeout must be between ${security.timeout.min} and ${security.timeout.max} minutes`);
    }

    // Validate JSON config
    try {
      JSON.parse(request.config);
    } catch {
      throw new Error('Invalid JSON configuration');
    }
  }

  public resolveScriptPath(scriptName: string): string {
    const security = this.getSecurityConfig();

    if (!security.allowedCommands.includes(scriptName)) {
      throw new Error(`Script not allowed: ${scriptName}`);
    }

    const paths = this.getPathsConfig();
    return `${paths.scripts}${scriptName}`;
  }

  public resolvePath(pathKey: keyof PathsConfig): string {
    const paths = this.getPathsConfig();
    return paths[pathKey];
  }

  private validateConfig(config: AppConfig): void {
    if (!config.name || !config.version) {
      throw new Error('Invalid configuration: missing name or version');
    }

    if (!config.server?.port || config.server.port < 1 || config.server.port > 65535) {
      throw new Error('Invalid server port configuration');
    }

    if (!config.security?.allowedCommands || config.security.allowedCommands.length === 0) {
      throw new Error('Invalid security configuration: no allowed commands');
    }

    if (!config.analysis?.systems || config.analysis.systems.length === 0) {
      throw new Error('Invalid analysis configuration: no systems defined');
    }
  }
}

// Export singleton instance
export const configService = ConfigService.getInstance();