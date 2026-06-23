import { defineConfig } from '@playwright/test';

export default defineConfig({
  testDir: './e2e',
  use: {
    baseURL: 'http://localhost:3001',
    screenshot: 'on',
    video: 'retain-on-failure',
  },
  webServer: {
    command: 'bin/test-server',
    url: 'http://localhost:3001/up',
    reuseExistingServer: false,
  },
  projects: [
    {
      name: 'chromium',
      use: { browserName: 'chromium' },
    },
  ],
});
