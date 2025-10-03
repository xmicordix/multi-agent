/**
 * 🚀 POWERSHELL EXECUTOR SERVICE 2025 - Professional Script Execution
 * Secure PowerShell execution service with comprehensive validation and monitoring
 */

import { configService, AnalysisRequest, AnalysisResult } from '../shared/config.service.ts';

export class PowerShellExecutor {
  private readonly configService = configService;

  constructor() {
    console.log('🔒 PowerShellExecutor initialized with enterprise security');
  }

  public async executeAnalysis(request: AnalysisRequest): Promise<AnalysisResult> {
    const startTime = Date.now();

    console.log(`🚀 [${new Date().toISOString()}] Starting analysis: ${request.systemName}`);
    console.log(`⚙️  Configuration: ${request.maxSessions} sessions, ${request.timeoutMinutes}min, dryRun: ${request.dryRun}`);

    try {
      // Load and validate configuration
      await this.configService.loadConfig();
      this.configService.validateAnalysisRequest(request);

      // Handle dry run mode
      if (request.dryRun) {
        return await this.executeDryRun(request, startTime);
      }

      // Generate configuration file
      const configPath = await this.writeConfigFile(request.systemName, request.config);

      // Build and execute secure command
      const command = this.buildSecureCommand(request, configPath);
      const result = await this.executeWithTimeout(command, request.timeoutMinutes * 60 * 1000);

      const executionTime = Date.now() - startTime;
      console.log(`✅ Analysis completed in ${executionTime}ms`);

      return {
        success: true,
        output: result.output,
        exitCode: result.exitCode,
        executionTime
      };

    } catch (error) {
      const executionTime = Date.now() - startTime;
      console.error(`❌ Analysis failed:`, error.message);

      return {
        success: false,
        error: error.message,
        exitCode: 1,
        executionTime
      };
    }
  }

  private async executeDryRun(request: AnalysisRequest, startTime: number): Promise<AnalysisResult> {
    console.log(`🧪 [DRY-RUN] Simulating analysis for ${request.systemName}`);

    // Simulate processing time
    await new Promise(resolve => setTimeout(resolve, 2000));

    const systemDef = this.configService.getAnalysisSystemById(request.systemName);
    const mockOutput = this.generateMockOutput(request, systemDef);

    return {
      success: true,
      output: mockOutput,
      exitCode: 0,
      executionTime: Date.now() - startTime
    };
  }

  private generateMockOutput(request: AnalysisRequest, systemDef: any): string {
    return `[DRY-RUN] Professional Analysis Simulation
System: ${systemDef?.name || request.systemName} ${systemDef?.icon || '🔍'}
Description: ${systemDef?.description || 'System analysis'}
Configuration: ${request.maxSessions} sessions, ${request.timeoutMinutes} minutes
Files Analyzed: ${Math.floor(Math.random() * 50) + 10}
Components Found: ${Math.floor(Math.random() * 20) + 5}
Risk Assessment: ${ ['LOW', 'MEDIUM', 'HIGH'][Math.floor(Math.random() * 3)] }
Recommendations: ${Math.floor(Math.random() * 10) + 3} optimization points identified
Status: SIMULATION_COMPLETE`;
  }

  private async writeConfigFile(systemName: string, config: string): Promise<string> {
    const sanitizedName = systemName.replace(/[^a-zA-Z0-9-_]/g, '');
    const dataPath = this.configService.resolvePath('data');
    const configPath = `${dataPath}/config-${sanitizedName}.json`;

    // Ensure data directory exists
    try {
      await Deno.mkdir(dataPath, { recursive: true });
    } catch (error) {
      if (!(error instanceof Deno.errors.AlreadyExists)) {
        throw error;
      }
    }

    await Deno.writeTextFile(configPath, config);
    console.log(`📝 Configuration saved: ${configPath}`);

    return configPath;
  }

  private buildSecureCommand(request: AnalysisRequest, configPath: string): string[] {
    const scriptPath = this.configService.resolveScriptPath('universal-system-analysis.ps1');

    return [
      'powershell.exe',
      '-ExecutionPolicy', 'Bypass',
      '-NoProfile',
      '-File', scriptPath,
      '-TargetSystem', request.systemName,
      '-ConfigFile', configPath,
      '-MaxConcurrentSessions', request.maxSessions.toString(),
      '-TimeoutMinutes', request.timeoutMinutes.toString(),
      '-ClaudeModel', 'sonnet'
    ];
  }

  private async executeWithTimeout(command: string[], timeoutMs: number): Promise<{output: string, exitCode: number}> {
    console.log(`🔧 Executing: ${command.join(' ')}`);

    const process = new Deno.Command(command[0], {
      args: command.slice(1),
      stdout: 'piped',
      stderr: 'piped',
      cwd: '.'
    });

    // Setup timeout
    const timeoutPromise = new Promise<never>((_, reject) => {
      setTimeout(() => reject(new Error(`Execution timeout after ${timeoutMs}ms`)), timeoutMs);
    });

    try {
      const result = await Promise.race([
        process.output(),
        timeoutPromise
      ]);

      const output = new TextDecoder().decode(result.stdout) +
                    new TextDecoder().decode(result.stderr);

      console.log(`📊 Process completed with exit code: ${result.code}`);

      return {
        output,
        exitCode: result.code
      };

    } catch (error) {
      throw new Error(`Execution failed: ${error.message}`);
    }
  }

  public async getExecutionStatus(): Promise<{
    activeExecutions: number;
    totalExecutions: number;
    lastExecution?: string;
  }> {
    // This would be enhanced with proper state management in a real application
    return {
      activeExecutions: 0,
      totalExecutions: 0,
      lastExecution: undefined
    };
  }
}