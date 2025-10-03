#!/usr/bin/env -S deno run --allow-net --allow-run --allow-read --allow-write
/**
 * 🚀 SIMPLE SECURE DENO SERVER 2025 - Universal System Analysis
 * Serveur HTTP natif Deno sans dépendances externes
 */

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
  private readonly scriptsPath = '../';

  constructor() {
    console.log('🔒 SecurePowerShellExecutor initialisé avec sandbox Deno');
  }

  async executeAnalysis(request: AnalysisRequest): Promise<PowerShellExecutionResult> {
    const startTime = Date.now();

    console.log(`🚀 [${new Date().toISOString()}] Démarrage analyse: ${request.systemName}`);

    try {
      // Validation sécurisée
      this.validateRequest(request);

      // Génération du fichier de configuration
      const configPath = await this.writeConfigFile(request.systemName, request.config);

      if (request.dryRun) {
        // Mode simulation
        await new Promise(resolve => setTimeout(resolve, 2000));
        return {
          success: true,
          output: `[DRY-RUN] Simulation d'analyse pour ${request.systemName}\nConfiguration: ${request.maxSessions} sessions, ${request.timeoutMinutes}min\nFichiers analysés: 23\nRisque: MEDIUM`,
          exitCode: 0,
          executionTime: Date.now() - startTime
        };
      }

      // Construction de la commande PowerShell sécurisée
      const command = this.buildSecureCommand(request, configPath);

      // Exécution avec timeout
      const result = await this.executeWithTimeout(command, request.timeoutMinutes * 60 * 1000);

      return {
        success: true,
        output: result.output,
        exitCode: result.exitCode,
        executionTime: Date.now() - startTime
      };

    } catch (error) {
      return {
        success: false,
        error: error.message,
        exitCode: 1,
        executionTime: Date.now() - startTime
      };
    }
  }

  private validateRequest(request: AnalysisRequest): void {
    if (!request.systemName || !/^[a-zA-Z0-9-_]+$/.test(request.systemName)) {
      throw new Error('Nom de système invalide');
    }
    if (request.maxSessions < 1 || request.maxSessions > 10) {
      throw new Error('Nombre de sessions doit être entre 1 et 10');
    }
    if (request.timeoutMinutes < 1 || request.timeoutMinutes > 60) {
      throw new Error('Timeout doit être entre 1 et 60 minutes');
    }
    try {
      JSON.parse(request.config);
    } catch {
      throw new Error('Configuration JSON invalide');
    }
  }

  private async writeConfigFile(systemName: string, config: string): Promise<string> {
    const configPath = `${this.scriptsPath}config-${systemName}.json`;
    await Deno.writeTextFile(configPath, config);
    console.log(`📝 Configuration sauvegardée: ${configPath}`);
    return configPath;
  }

  private buildSecureCommand(request: AnalysisRequest, configPath: string): string[] {
    return [
      'powershell.exe',
      '-ExecutionPolicy', 'Bypass',
      '-NoProfile',
      '-File', './universal-system-analysis.ps1',
      '-TargetSystem', request.systemName,
      '-ConfigFile', configPath,
      '-MaxConcurrentSessions', request.maxSessions.toString(),
      '-TimeoutMinutes', request.timeoutMinutes.toString(),
      '-ClaudeModel', 'sonnet'
    ];
  }

  private async executeWithTimeout(command: string[], timeoutMs: number): Promise<{output: string, exitCode: number}> {
    console.log(`🔧 Exécution: ${command.join(' ')}`);

    const process = new Deno.Command(command[0], {
      args: command.slice(1),
      stdout: 'piped',
      stderr: 'piped',
      cwd: '.'
    });

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

      return { output, exitCode: result.code };
    } catch (error) {
      throw new Error(`Exécution échouée: ${error.message}`);
    }
  }
}

// Configuration CORS
function addCorsHeaders(headers: Headers) {
  headers.set('Access-Control-Allow-Origin', '*');  // Permet tous les domaines pour les fichiers locaux
  headers.set('Access-Control-Allow-Methods', 'GET, POST, OPTIONS, PUT, DELETE');
  headers.set('Access-Control-Allow-Headers', 'Content-Type, Authorization, X-Requested-With');
  headers.set('Access-Control-Allow-Credentials', 'false');  // Doit être false avec origin *
}

// Gestionnaire de requêtes HTTP
async function handleRequest(request: Request): Promise<Response> {
  const url = new URL(request.url);
  const headers = new Headers();
  addCorsHeaders(headers);

  // Gestion CORS preflight
  if (request.method === 'OPTIONS') {
    return new Response(null, { status: 200, headers });
  }

  console.log(`${request.method} ${url.pathname}`);

  try {
    // Route de santé
    if (url.pathname === '/api/health') {
      const healthData = {
        status: 'healthy',
        timestamp: new Date().toISOString(),
        runtime: 'Deno',
        version: Deno.version.deno
      };
      headers.set('Content-Type', 'application/json');
      return new Response(JSON.stringify(healthData), { status: 200, headers });
    }

    // Route d'analyse
    if (url.pathname === '/api/analyze' && request.method === 'POST') {
      const body = await request.json() as AnalysisRequest;
      const executor = new SecurePowerShellExecutor();
      const result = await executor.executeAnalysis(body);

      headers.set('Content-Type', 'application/json');
      return new Response(JSON.stringify(result), {
        status: result.success ? 200 : 500,
        headers
      });
    }

    // Route pour les fichiers de résultats
    if (url.pathname.startsWith('/api/results/')) {
      const filename = url.pathname.split('/').pop();
      if (!filename || !/^[a-zA-Z0-9-_.]+\.json$/.test(filename)) {
        headers.set('Content-Type', 'application/json');
        return new Response(JSON.stringify({ error: 'Nom de fichier invalide' }), {
          status: 400,
          headers
        });
      }

      try {
        const filePath = `../${filename}`;
        const content = await Deno.readTextFile(filePath);
        headers.set('Content-Type', 'application/json');
        return new Response(content, { status: 200, headers });
      } catch {
        headers.set('Content-Type', 'application/json');
        return new Response(JSON.stringify({ error: 'Fichier non trouvé' }), {
          status: 404,
          headers
        });
      }
    }

    // Servir l'interface web
    if (url.pathname === '/' || url.pathname === '/index.html') {
      try {
        const htmlContent = await Deno.readTextFile('./secure-frontend.html');
        headers.set('Content-Type', 'text/html; charset=utf-8');
        return new Response(htmlContent, { status: 200, headers });
      } catch {
        headers.set('Content-Type', 'text/plain');
        return new Response('Interface non trouvée', { status: 404, headers });
      }
    }

    // 404 pour routes non trouvées
    headers.set('Content-Type', 'application/json');
    return new Response(JSON.stringify({ error: 'Route non trouvée' }), {
      status: 404,
      headers
    });

  } catch (error) {
    console.error('Erreur serveur:', error.message);
    headers.set('Content-Type', 'application/json');
    return new Response(JSON.stringify({ error: 'Erreur serveur interne' }), {
      status: 500,
      headers
    });
  }
}

// Démarrage du serveur
const PORT = 8080;
console.log(`🚀 Serveur Deno sécurisé démarré sur http://localhost:${PORT}`);
console.log(`🔒 Permissions: --allow-net --allow-run --allow-read --allow-write`);
console.log(`📊 API REST disponible pour analyse universelle`);

Deno.serve({ port: PORT }, handleRequest);