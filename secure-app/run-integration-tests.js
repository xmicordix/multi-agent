#!/usr/bin/env node

/**
 * INTEGRATION TEST RUNNER SCRIPT
 * Revolutionary Control Center Ultimate IDE 2025
 *
 * Phase 8: Integration Testing Expert - Test Execution Script
 * Runs comprehensive integration tests with reporting and validation
 */

const { spawn } = require('child_process')
const fs = require('fs')
const path = require('path')

class IntegrationTestRunner {
  constructor() {
    this.testSuites = [
      'session-bridge-integration.test.ts',
      'unified-persistence-integration.test.ts',
      'dual-mode-integration.test.ts',
      'ipc-realtime-integration.test.ts',
      'claude-cli-workflow-integration.test.ts',
      'error-propagation-recovery.test.ts',
      'performance-health-metrics.test.ts',
      'comprehensive-integration-runner.test.ts'
    ]
  }

  async runTests() {
    console.log('🚀 Revolutionary Control Center - Integration Test Runner')
    console.log('=' * 60)

    const startTime = Date.now()

    try {
      // Create test reports directory
      this.ensureReportsDirectory()

      // Run Jest with integration configuration
      const jestResult = await this.runJestTests()

      // Generate summary report
      const summary = await this.generateSummaryReport(jestResult, Date.now() - startTime)

      // Display results
      this.displayResults(summary)

      // Exit with appropriate code
      process.exit(jestResult.success ? 0 : 1)

    } catch (error) {
      console.error('❌ Integration test runner failed:', error)
      process.exit(1)
    }
  }

  ensureReportsDirectory() {
    const reportsDir = path.join(process.cwd(), 'test-reports', 'integration')
    if (!fs.existsSync(reportsDir)) {
      fs.mkdirSync(reportsDir, { recursive: true })
    }
  }

  async runJestTests() {
    return new Promise((resolve, reject) => {
      console.log('🧪 Running Jest Integration Tests...\n')

      const jestProcess = spawn('npx', [
        'jest',
        '--config=tests/integration/jest.integration.config.js',
        '--runInBand', // Run tests serially for integration
        '--detectOpenHandles',
        '--forceExit'
      ], {
        stdio: 'inherit',
        shell: true
      })

      jestProcess.on('close', (code) => {
        const success = code === 0

        resolve({
          success,
          exitCode: code,
          timestamp: new Date()
        })
      })

      jestProcess.on('error', (error) => {
        reject(error)
      })
    })
  }

  async generateSummaryReport(jestResult, duration) {
    const summary = {
      timestamp: new Date(),
      duration,
      success: jestResult.success,
      exitCode: jestResult.exitCode,
      testSuites: this.testSuites.length,
      environment: {
        node: process.version,
        platform: process.platform,
        arch: process.arch,
        cwd: process.cwd()
      }
    }

    // Try to read Jest results if available
    try {
      const resultsPath = path.join(process.cwd(), 'test-reports', 'integration', 'integration-test-results.xml')
      if (fs.existsSync(resultsPath)) {
        summary.hasDetailedResults = true
      }
    } catch (error) {
      // Results file not available
    }

    // Write summary to file
    const summaryPath = path.join(process.cwd(), 'test-reports', 'integration', 'summary.json')
    fs.writeFileSync(summaryPath, JSON.stringify(summary, null, 2))

    return summary
  }

  displayResults(summary) {
    console.log('\n' + '=' * 60)
    console.log('📊 INTEGRATION TEST RESULTS SUMMARY')
    console.log('=' * 60)

    console.log(`⏱️  Duration: ${(summary.duration / 1000).toFixed(2)}s`)
    console.log(`🧪 Test Suites: ${summary.testSuites}`)
    console.log(`🖥️  Environment: Node ${summary.environment.node} on ${summary.environment.platform}`)

    if (summary.success) {
      console.log('✅ Result: ALL TESTS PASSED')
      console.log('\n🎉 Integration tests completed successfully!')
      console.log('   All service integrations are functioning correctly.')
    } else {
      console.log('❌ Result: TESTS FAILED')
      console.log(`   Exit Code: ${summary.exitCode}`)
      console.log('\n⚠️  Integration test failures detected!')
      console.log('   Please review the detailed test output above.')
    }

    console.log('\n📋 Reports Generated:')
    console.log('   • HTML Report: test-reports/integration/integration-test-report.html')
    console.log('   • XML Results: test-reports/integration/integration-test-results.xml')
    console.log('   • Summary: test-reports/integration/summary.json')

    if (summary.success) {
      console.log('\n🚀 Revolutionary Control Center integration is ready for deployment!')
    } else {
      console.log('\n🔧 Please fix integration issues before deployment.')
    }

    console.log('=' * 60)
  }
}

// Command line interface
if (require.main === module) {
  const args = process.argv.slice(2)

  if (args.includes('--help') || args.includes('-h')) {
    console.log(`
Integration Test Runner for Revolutionary Control Center

Usage: node scripts/run-integration-tests.js [options]

Options:
  --help, -h     Show this help message
  --verbose, -v  Enable verbose output

Test Suites:
  • SessionBridge ↔ ClaudeCliManager Integration
  • UnifiedPersistenceService Strategy Switching
  • Dual-Mode Switching with State Preservation
  • Real-time IPC Data Flow
  • Claude Code CLI Workflow Integration
  • Error Propagation and Recovery
  • Performance Benchmarks and Health Metrics
  • Comprehensive Integration Validation

Reports:
  Generated in test-reports/integration/
  • HTML visual report
  • XML JUnit format
  • JSON summary
`)
    process.exit(0)
  }

  // Run integration tests
  const runner = new IntegrationTestRunner()
  runner.runTests().catch(error => {
    console.error('Integration test runner crashed:', error)
    process.exit(1)
  })
}