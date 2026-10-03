import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './tests',
  timeout: 60_000,
  expect: { timeout: 10_000 },
  fullyParallel: false,
  retries: 0,
  workers: 1,
  reporter: [
    ['list'],
    ['html', { 
      open: 'never', 
      outputFolder: 'playwright-report',
      attachmentsBaseURL: 'attachments'
    }],
    ['json', { outputFile: 'test-results/results.json' }]
  ],
  use: {
    baseURL: 'http://127.0.0.1:8000',
    trace: 'on',                    // Always keep trace
    screenshot: 'on',               // Always take screenshots
    video: 'on',                    // Always record video
    actionTimeout: 15_000,
  },
  projects: [
    {
      name: 'api',
      testMatch: /api\/.*.spec.ts/,
    },
    {
      name: 'e2e',
      testMatch: /e2e\/.*.spec.ts/,
      use: { ...devices['Desktop Chrome'] },
    },
  ],
});
