import { defineConfig } from '@playwright/test';

export default defineConfig({
  testDir: './e2e',
  use: {
    baseURL: 'http://localhost:3001',
    screenshot: 'on',
    video: 'retain-on-failure',
  },
  webServer: {
    command: 'RAILS_ENV=test bin/rails server -p 3001',
    url: 'http://localhost:3001',
    reuseExistingServer: false,
  },
  projects: [
    {
      name: 'chromium',
      use: { browserName: 'chromium' },
    },
  ],
});
