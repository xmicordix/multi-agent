#!/usr/bin/env -S deno run --allow-net --allow-run --allow-read --allow-write
/**
 * 🚀 SECURE DENO SERVER 2025 - Universal System Analysis
 * Sécurisé par défaut avec permissions explicites
 */

import { Application, Router } from "https://deno.land/x/oak@v16.1.0/mod.ts";
import { oakCors } from "https://deno.land/x/cors@v1.2.2/mod.ts";

interface AnalysisRequest {
  systemName: string;
  config: string;
  maxSessions: number;
  timeoutMinutes: number;
  dryRun: boolean;
}

interface PowerShellExecutionResult {
  success: boolean;
  output?: string;
  error?: string;
  exitCode: number;
  executionTime: number;
}

class SecurePowerShellExecutor {
  private readonly allowedCommands = [
    'universal-system-analysis.ps1',
    'parallel-system-analysis.ps1',
    'update-phases-from-analysis.ps1',
    'execute-migration-orchestrator.ps1'
  ];

  private readonly scriptsPath = '../';

  constructor() {
    console.log('🔒 SecurePowerShellExecutor initialisé avec sandbox Deno');
  }

  async executeAnalysis(request: AnalysisRequest): Promise<PowerShellExecutionResult> {
    const startTime = Date.now();

    console.log(`🚀 [${new Date().toISOString()}] Démarrage analyse: ${request.systemName}`);
    console.log(`⚙️  Configuration: ${request.maxSessions} sessions, ${request.timeoutMinutes}min, dryRun: ${request.dryRun}`);

    try {
      // Validation sécurisée
      this.validateRequest(request);

      // Génération du fichier de configuration
      const configPath = await this.writeConfigFile(request.systemName, request.config);

      // Construction de la commande PowerShell sécurisée
      const command = this.buildSecureCommand(request, configPath);

      // Exécution avec timeout et monitoring
      const result = await this.executeWithTimeout(command, request.timeoutMinutes * 60 * 1000);

      const executionTime = Date.now() - startTime;

      console.log(`✅ Analyse terminée en ${executionTime}ms`);

      return {
        success: true,
        output: result.output,
        exitCode: result.exitCode,
        executionTime
      };

    } catch (error) {
      const executionTime = Date.now() - startTime;
      console.error(`❌ Erreur lors de l'analyse:`, error.message);

      return {
        success: false,
        error: error.message,
        exitCode: 1,
        executionTime
      };
    }
  }

  private validateRequest(request: AnalysisRequest): void {
    // Validation des paramètres
    if (!request.systemName || request.systemName.length > 50) {
      throw new Error('Nom de système invalide');
    }

    if (!/^[a-zA-Z0-9-_]+$/.test(request.systemName)) {
      throw new Error('Nom de système contient des caractères invalides');
    }

    if (request.maxSessions < 1 || request.maxSessions > 10) {
      throw new Error('Nombre de sessions doit être entre 1 et 10');
    }

    if (request.timeoutMinutes < 1 || request.timeoutMinutes > 60) {
      throw new Error('Timeout doit être entre 1 et 60 minutes');
    }

    // Validation JSON config
    try {
      JSON.parse(request.config);
    } catch {
      throw new Error('Configuration JSON invalide');
    }
  }

  private async writeConfigFile(systemName: string, config: string): Promise<string> {
    const sanitizedName = systemName.replace(/[^a-zA-Z0-9-_]/g, '');
    const configPath = `${this.scriptsPath}config-${sanitizedName}.json`;

    await Deno.writeTextFile(configPath, config);
    console.log(`📝 Configuration sauvegardée: ${configPath}`);

    return configPath;
  }

  private buildSecureCommand(request: AnalysisRequest, configPath: string): string[] {
    const scriptPath = `${this.scriptsPath}universal-system-analysis.ps1`;

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
    console.log(`🔧 Exécution commande: ${command.join(' ')}`);

    const process = new Deno.Command(command[0], {
      args: command.slice(1),
      stdout: 'piped',
      stderr: 'piped',
      cwd: this.scriptsPath
    });

    // Exécution avec timeout
    const timeoutPromise = new Promise<never>((_, reject) => {
      setTimeout(() => reject(new Error('Timeout dépassé')), timeoutMs);
    });

    try {
      const result = await Promise.race([
        process.output(),
        timeoutPromise
      ]);

      const output = new TextDecoder().decode(result.stdout) +
                    new TextDecoder().decode(result.stderr);

      return {
        output,
        exitCode: result.code
      };

    } catch (error) {
      throw new Error(`Exécution échouée: ${error.message}`);
    }
  }
}

// Configuration du serveur
const app = new Application();
const router = new Router();
const executor = new SecurePowerShellExecutor();

// Middleware de sécurité
app.use(oakCors({
  origin: ['http://localhost:3000', 'tauri://localhost'],
  credentials: true
}));

// Middleware de logging
app.use(async (ctx, next) => {
  const start = Date.now();
  await next();
  const ms = Date.now() - start;
  console.log(`${ctx.request.method} ${ctx.request.url} - ${ms}ms`);
});

// Routes API
router.post('/api/analyze', async (ctx) => {
  try {
    const body = await ctx.request.body({ type: 'json' }).value as AnalysisRequest;
    const result = await executor.executeAnalysis(body);

    ctx.response.status = result.success ? 200 : 500;
    ctx.response.body = result;
  } catch (error) {
    console.error('Erreur API:', error.message);
    ctx.response.status = 400;
    ctx.response.body = {
      success: false,
      error: error.message
    };
  }
});

router.get('/api/health', (ctx) => {
  ctx.response.body = {
    status: 'healthy',
    timestamp: new Date().toISOString(),
    runtime: 'Deno',
    version: Deno.version.deno
  };
});

router.get('/api/results/:filename', async (ctx) => {
  try {
    const filename = ctx.params.filename;

    // Validation sécurisée du nom de fichier
    if (!/^[a-zA-Z0-9-_.]+\.json$/.test(filename)) {
      throw new Error('Nom de fichier invalide');
    }

    const filePath = `${executor['scriptsPath']}${filename}`;
    const content = await Deno.readTextFile(filePath);

    ctx.response.headers.set('Content-Type', 'application/json');
    ctx.response.body = JSON.parse(content);
  } catch (error) {
    ctx.response.status = 404;
    ctx.response.body = { error: 'Fichier non trouvé' };
  }
});

app.use(router.routes());
app.use(router.allowedMethods());

// Démarrage du serveur
const PORT = 8080;
console.log(`🚀 Serveur Deno sécurisé démarré sur http://localhost:${PORT}`);
console.log(`🔒 Permissions: --allow-net --allow-run --allow-read --allow-write`);
console.log(`📊 Interface d'analyse universelle disponible`);

await app.listen({ port: PORT });