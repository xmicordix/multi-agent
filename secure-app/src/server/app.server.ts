#!/usr/bin/env -S deno run --allow-net --allow-run --allow-read --allow-write
/**
 * 🚀 SECURE UNIVERSAL ANALYSIS SERVER 2025 - Professional Edition
 * Enterprise-grade secure server with proper architecture and configuration management
 */

import { configService } from '../shared/config.service.ts';
import { PowerShellExecutor } from './powershell.executor.ts';
import { AdvancedPresetsService } from '../shared/presets.service.ts';
import { AdvancedParallelExecutor } from './advanced.executor.ts';

class SecureAnalysisServer {
  private executor: PowerShellExecutor;
  private configService = configService;
  private presetsService: AdvancedPresetsService;
  private advancedExecutor: AdvancedParallelExecutor;

  constructor() {
    this.executor = new PowerShellExecutor();
    this.presetsService = new AdvancedPresetsService(this.configService);
    this.advancedExecutor = new AdvancedParallelExecutor(this.presetsService);
  }

  public async initialize(): Promise<void> {
    try {
      // Load configuration
      const config = await this.configService.loadConfig();
      console.log(`🚀 ${config.name} v${config.version}`);
      console.log(`📝 ${config.description}`);

      // Load advanced presets
      await this.presetsService.loadPresetsConfig();
      const presetStats = this.presetsService.getPresetStats();
      console.log(`🎯 Advanced Presets: ${presetStats.total} systems, ${presetStats.totalDomains} domains, ${presetStats.totalKeywords} keywords`);

      // Ensure required directories exist
      await this.ensureDirectories();

      console.log('✅ Server initialization completed');
    } catch (error) {
      console.error('❌ Server initialization failed:', error.message);
      throw error;
    }
  }

  private async ensureDirectories(): Promise<void> {
    const paths = this.configService.getPathsConfig();

    for (const [key, path] of Object.entries(paths)) {
      if (key !== 'scripts') { // Don't create scripts directory as it should already exist
        try {
          await Deno.mkdir(path, { recursive: true });
          console.log(`📁 Ensured directory: ${path}`);
        } catch (error) {
          if (!(error instanceof Deno.errors.AlreadyExists)) {
            console.warn(`⚠️  Failed to create directory ${path}:`, error.message);
          }
        }
      }
    }
  }

  public async start(): Promise<void> {
    await this.initialize();

    const serverConfig = this.configService.getServerConfig();
    const securityConfig = this.configService.getSecurityConfig();

    console.log(`🔒 Security Features Enabled:`);
    console.log(`   • Deno Runtime Sandbox`);
    console.log(`   • Request Validation & Sanitization`);
    console.log(`   • Timeout Protection (${securityConfig.timeout.min}-${securityConfig.timeout.max} ${securityConfig.timeout.unit})`);
    console.log(`   • Allowed Commands: ${securityConfig.allowedCommands.length} scripts`);
    console.log(`   • Sessions Limit: ${securityConfig.maxSessions.min}-${securityConfig.maxSessions.max}`);

    console.log(`🌐 Starting server on http://${serverConfig.host}:${serverConfig.port}`);

    Deno.serve({
      port: serverConfig.port,
      hostname: serverConfig.host
    }, this.handleRequest.bind(this));
  }

  private async handleRequest(request: Request): Promise<Response> {
    const url = new URL(request.url);
    const headers = new Headers();

    this.addCorsHeaders(headers);

    // Handle CORS preflight
    if (request.method === 'OPTIONS') {
      return new Response(null, { status: 200, headers });
    }

    console.log(`${request.method} ${url.pathname}`);

    try {
      // Health check endpoint
      if (url.pathname === '/api/health') {
        return this.handleHealthCheck(headers);
      }

      // Analysis endpoint
      if (url.pathname === '/api/analyze' && request.method === 'POST') {
        return await this.handleAnalysis(request, headers);
      }

      // Advanced analysis endpoint
      if (url.pathname === '/api/analyze/advanced' && request.method === 'POST') {
        return await this.handleAdvancedAnalysis(request, headers);
      }

      // Configuration endpoint
      if (url.pathname === '/api/config' && request.method === 'GET') {
        return this.handleConfigRequest(headers);
      }

      // Presets endpoint
      if (url.pathname === '/api/presets' && request.method === 'GET') {
        return this.handlePresetsRequest(headers);
      }

      // Preset detail endpoint
      if (url.pathname.startsWith('/api/presets/') && request.method === 'GET') {
        return this.handlePresetDetailRequest(url, headers);
      }

      // Status endpoint
      if (url.pathname === '/api/status' && request.method === 'GET') {
        return await this.handleStatusRequest(headers);
      }

      // Results endpoint
      if (url.pathname.startsWith('/api/results/')) {
        return await this.handleResultsRequest(url, headers);
      }

      // Serve frontend interface
      if (url.pathname === '/' || url.pathname === '/index.html') {
        return await this.handleFrontendRequest(headers);
      }

      // Serve advanced interface
      if (url.pathname === '/advanced' || url.pathname === '/expert') {
        return await this.handleAdvancedFrontendRequest(headers);
      }

      // 404 for unknown routes
      return this.createErrorResponse(404, 'Route not found', headers);

    } catch (error) {
      console.error('❌ Request handling error:', error.message);
      return this.createErrorResponse(500, 'Internal server error', headers);
    }
  }

  private addCorsHeaders(headers: Headers): void {
    const serverConfig = this.configService.getServerConfig();

    headers.set('Access-Control-Allow-Origin', '*');
    headers.set('Access-Control-Allow-Methods', 'GET, POST, OPTIONS, PUT, DELETE');
    headers.set('Access-Control-Allow-Headers', 'Content-Type, Authorization, X-Requested-With');
    headers.set('Access-Control-Allow-Credentials', 'false');
  }

  private handleHealthCheck(headers: Headers): Response {
    const config = this.configService.getConfig();

    const healthData = {
      status: 'healthy',
      timestamp: new Date().toISOString(),
      runtime: 'Deno',
      version: Deno.version.deno,
      app: {
        name: config.name,
        version: config.version
      }
    };

    headers.set('Content-Type', 'application/json');
    return new Response(JSON.stringify(healthData), { status: 200, headers });
  }

  private async handleAnalysis(request: Request, headers: Headers): Response {
    try {
      const analysisRequest = await request.json();
      const result = await this.executor.executeAnalysis(analysisRequest);

      headers.set('Content-Type', 'application/json');
      return new Response(JSON.stringify(result), {
        status: result.success ? 200 : 500,
        headers
      });
    } catch (error) {
      console.error('❌ Analysis request error:', error.message);
      return this.createErrorResponse(400, error.message, headers);
    }
  }

  private async handleAdvancedAnalysis(request: Request, headers: Headers): Response {
    try {
      const analysisRequest = await request.json();

      console.log(`🚀 Advanced analysis request: ${analysisRequest.systemName}`);

      const result = await this.advancedExecutor.executeAdvancedAnalysis(analysisRequest);

      headers.set('Content-Type', 'application/json');
      return new Response(JSON.stringify({
        success: true,
        data: result,
        timestamp: new Date().toISOString()
      }), {
        status: 200,
        headers
      });
    } catch (error) {
      console.error('❌ Advanced analysis request error:', error.message);
      return this.createErrorResponse(400, error.message, headers);
    }
  }

  private handleConfigRequest(headers: Headers): Response {
    const config = this.configService.getConfig();

    // Return sanitized config (without sensitive data)
    const publicConfig = {
      name: config.name,
      version: config.version,
      description: config.description,
      security: {
        maxSessions: config.security.maxSessions,
        timeout: config.security.timeout
      },
      analysis: config.analysis
    };

    headers.set('Content-Type', 'application/json');
    return new Response(JSON.stringify(publicConfig), { status: 200, headers });
  }

  private handlePresetsRequest(headers: Headers): Response {
    try {
      const presetNames = this.presetsService.getPresetNames();
      const presetsByPriority = this.presetsService.getPresetsByPriority();
      const stats = this.presetsService.getPresetStats();
      const analysisModes = this.presetsService.getAnalysisModes();
      const phaseExecution = this.presetsService.getPhaseExecution();

      const response = {
        presets: presetNames,
        presets_by_priority: presetsByPriority,
        statistics: stats,
        analysis_modes: analysisModes,
        phase_execution: phaseExecution
      };

      headers.set('Content-Type', 'application/json');
      return new Response(JSON.stringify(response), { status: 200, headers });
    } catch (error) {
      console.error('❌ Presets request error:', error.message);
      return this.createErrorResponse(400, error.message, headers);
    }
  }

  private handlePresetDetailRequest(url: URL, headers: Headers): Response {
    try {
      const presetName = url.pathname.split('/').pop();

      if (!presetName) {
        return this.createErrorResponse(400, 'Preset name is required', headers);
      }

      const preset = this.presetsService.getPreset(presetName);
      const validation = this.presetsService.validatePreset(preset);
      const analysisRequest = this.presetsService.generateAnalysisRequest(presetName);
      const prompt = this.presetsService.generateAdvancedPrompt(presetName);

      const response = {
        preset,
        validation,
        analysis_request: analysisRequest,
        generated_prompt: prompt
      };

      headers.set('Content-Type', 'application/json');
      return new Response(JSON.stringify(response), { status: 200, headers });
    } catch (error) {
      console.error('❌ Preset detail request error:', error.message);
      return this.createErrorResponse(404, `Preset not found: ${error.message}`, headers);
    }
  }

  private async handleStatusRequest(headers: Headers): Response {
    const status = await this.executor.getExecutionStatus();

    headers.set('Content-Type', 'application/json');
    return new Response(JSON.stringify(status), { status: 200, headers });
  }

  private async handleResultsRequest(url: URL, headers: Headers): Response {
    const filename = url.pathname.split('/').pop();

    if (!filename || !/^[a-zA-Z0-9-_.]+\.json$/.test(filename)) {
      return this.createErrorResponse(400, 'Invalid filename', headers);
    }

    try {
      const dataPath = this.configService.resolvePath('data');
      const filePath = `${dataPath}/${filename}`;
      const content = await Deno.readTextFile(filePath);

      headers.set('Content-Type', 'application/json');
      return new Response(content, { status: 200, headers });
    } catch {
      return this.createErrorResponse(404, 'File not found', headers);
    }
  }

  private async handleFrontendRequest(headers: Headers): Response {
    try {
      const htmlContent = await Deno.readTextFile('./src/client/index.html');
      headers.set('Content-Type', 'text/html; charset=utf-8');
      return new Response(htmlContent, { status: 200, headers });
    } catch {
      return this.createErrorResponse(404, 'Frontend interface not found', headers);
    }
  }

  private async handleAdvancedFrontendRequest(headers: Headers): Response {
    try {
      const htmlContent = await Deno.readTextFile('./src/client/advanced-interface.html');
      headers.set('Content-Type', 'text/html; charset=utf-8');
      return new Response(htmlContent, { status: 200, headers });
    } catch {
      return this.createErrorResponse(404, 'Advanced interface not found', headers);
    }
  }

  private createErrorResponse(status: number, message: string, headers: Headers): Response {
    headers.set('Content-Type', 'application/json');
    return new Response(
      JSON.stringify({ error: message, timestamp: new Date().toISOString() }),
      { status, headers }
    );
  }
}

// Start the server
const server = new SecureAnalysisServer();

if (import.meta.main) {
  try {
    await server.start();
  } catch (error) {
    console.error('💥 Server startup failed:', error.message);
    Deno.exit(1);
  }
}