import { test, expect } from '@playwright/test';

test.describe('月次報告書', () => {
  test('PDFとして保存ボタンが表示される', async ({ page }) => {
    await test.step('月次報告書ページにアクセスする', async () => {
      await page.goto('/report');
    });

    await test.step('PDFとして保存ボタンが表示されることを確認する', async () => {
      await expect(page.getByRole('button', { name: /PDFとして保存/ })).toBeVisible();
    });
  });

  test('PDFとして保存ボタンを押すとwindow.printが呼ばれる', async ({ page }) => {
    await test.step('月次報告書ページにアクセスする', async () => {
      await page.goto('/report');
    });

    await test.step('window.printをモックする', async () => {
      await page.evaluate(() => {
        (window as any).__printCalled = false;
        window.print = () => { (window as any).__printCalled = true; };
      });
    });

    await test.step('PDFとして保存ボタンをクリックする', async () => {
      await page.getByRole('button', { name: /PDFとして保存/ }).click();
    });

    await test.step('window.printが呼ばれたことを確認する', async () => {
      const called = await page.evaluate(() => (window as any).__printCalled);
      expect(called).toBe(true);
    });
  });

  test('印刷時にナビゲーションとヘッダーが非表示になる', async ({ page }) => {
    await test.step('月次報告書ページにアクセスする', async () => {
      await page.goto('/report');
    });

    await test.step('印刷メディアをエミュレートする', async () => {
      await page.emulateMedia({ media: 'print' });
    });

    await test.step('ヘッダーが非表示になることを確認する', async () => {
      const header = page.locator('header');
      await expect(header).toBeHidden();
    });

    await test.step('ボトムナビが非表示になることを確認する', async () => {
      const nav = page.locator('nav.bottom-nav');
      await expect(nav).toBeHidden();
    });

    await test.step('PDFボタンが非表示になることを確認する', async () => {
      const pdfBtn = page.locator('.report-actions');
      await expect(pdfBtn).toBeHidden();
    });

    await test.step('レポート本文のカードが表示されることを確認する', async () => {
      await expect(page.locator('.card').first()).toBeVisible();
    });
  });
});
