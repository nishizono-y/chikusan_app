import { test, expect } from '@playwright/test';

test('【動画確認用】わざと失敗するテスト', async ({ page }) => {
  await page.goto('/daily_records');

  // 存在しないテキストを期待することで意図的に失敗させる
  await expect(page.getByText('このテキストは絶対に存在しない')).toBeVisible();
});
