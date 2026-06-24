import { test, expect } from '@playwright/test';

test.describe('ボトムナビ', () => {
  test('ホームページでホームナビアイテムがアクティブになる', async ({ page }) => {
    await test.step('ホームページにアクセスする', async () => {
      await page.goto('/');
    });

    await test.step('ホームのナビアイテムがアクティブであることを確認する', async () => {
      const homeNav = page.locator('.nav-item', { hasText: 'ホーム' });
      await expect(homeNav).toHaveClass(/active/);
    });

    await test.step('日次記録のナビアイテムがアクティブでないことを確認する', async () => {
      const dailyNav = page.locator('.nav-item', { hasText: '日次記録' });
      await expect(dailyNav).not.toHaveClass(/active/);
    });

    await test.step('出荷記録のナビアイテムがアクティブでないことを確認する', async () => {
      const shipmentsNav = page.locator('.nav-item', { hasText: '出荷記録' });
      await expect(shipmentsNav).not.toHaveClass(/active/);
    });
  });

  test('日次記録ページでナビアイテムがアクティブになる', async ({ page }) => {
    await test.step('日次記録の一覧ページにアクセスする', async () => {
      await page.goto('/daily_records');
    });

    await test.step('日次記録のナビアイテムがアクティブであることを確認する', async () => {
      const dailyNav = page.locator('.nav-item', { hasText: '日次記録' });
      await expect(dailyNav).toHaveClass(/active/);
    });

    await test.step('ホームのナビアイテムがアクティブでないことを確認する', async () => {
      const homeNav = page.locator('.nav-item', { hasText: 'ホーム' });
      await expect(homeNav).not.toHaveClass(/active/);
    });

    await test.step('出荷記録のナビアイテムがアクティブでないことを確認する', async () => {
      const shipmentsNav = page.locator('.nav-item', { hasText: '出荷記録' });
      await expect(shipmentsNav).not.toHaveClass(/active/);
    });
  });

  test('出荷記録ページでナビアイテムがアクティブになる', async ({ page }) => {
    await test.step('出荷記録の一覧ページにアクセスする', async () => {
      await page.goto('/shipments');
    });

    await test.step('出荷記録のナビアイテムがアクティブであることを確認する', async () => {
      const shipmentsNav = page.locator('.nav-item', { hasText: '出荷記録' });
      await expect(shipmentsNav).toHaveClass(/active/);
    });

    await test.step('ホームのナビアイテムがアクティブでないことを確認する', async () => {
      const homeNav = page.locator('.nav-item', { hasText: 'ホーム' });
      await expect(homeNav).not.toHaveClass(/active/);
    });

    await test.step('日次記録のナビアイテムがアクティブでないことを確認する', async () => {
      const dailyNav = page.locator('.nav-item', { hasText: '日次記録' });
      await expect(dailyNav).not.toHaveClass(/active/);
    });
  });

  test('ナビからホームページへ遷移できる', async ({ page }) => {
    await test.step('日次記録の一覧ページにアクセスする', async () => {
      await page.goto('/daily_records');
    });

    await test.step('ボトムナビのホームをクリックする', async () => {
      await page.locator('.nav-item', { hasText: 'ホーム' }).click();
    });

    await test.step('ホームページに遷移することを確認する', async () => {
      await expect(page).toHaveURL('/');
      await expect(page.getByText('の状況')).toBeVisible();
    });
  });

  test('ナビから日次記録ページへ遷移できる', async ({ page }) => {
    await test.step('出荷記録の一覧ページにアクセスする', async () => {
      await page.goto('/shipments');
    });

    await test.step('ボトムナビの日次記録をクリックする', async () => {
      await page.locator('.nav-item', { hasText: '日次記録' }).click();
    });

    await test.step('日次記録の一覧ページに遷移することを確認する', async () => {
      await expect(page).toHaveURL(/\/daily_records/);
      await expect(page.getByText('日次記録一覧')).toBeVisible();
    });
  });

  test('ナビから出荷記録ページへ遷移できる', async ({ page }) => {
    await test.step('日次記録の一覧ページにアクセスする', async () => {
      await page.goto('/daily_records');
    });

    await test.step('ボトムナビの出荷記録をクリックする', async () => {
      await page.locator('.nav-item', { hasText: '出荷記録' }).click();
    });

    await test.step('出荷記録の一覧ページに遷移することを確認する', async () => {
      await expect(page).toHaveURL(/\/shipments/);
      await expect(page.getByText('出荷記録一覧')).toBeVisible();
    });
  });
});
