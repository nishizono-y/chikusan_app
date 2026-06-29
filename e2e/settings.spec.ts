import { test, expect } from '@playwright/test';

test.describe('設定', () => {
  test('設定ページが表示される', async ({ page }) => {
    await test.step('設定ページにアクセスする', async () => {
      await page.goto('/setting/edit');
    });

    await test.step('ページタイトルが「設定」であることを確認する', async () => {
      await expect(page).toHaveTitle(/設定/);
      await expect(page.getByText('飼料残量アラート')).toBeVisible();
    });

    await test.step('しきい値入力欄が表示されることを確認する', async () => {
      await expect(page.locator('input[name="setting[value]"]')).toBeVisible();
    });
  });

  test('ボトムナビの設定リンクから遷移できる', async ({ page }) => {
    await test.step('ホームページにアクセスする', async () => {
      await page.goto('/');
    });

    await test.step('ボトムナビの「設定」をクリックする', async () => {
      await page.getByRole('link', { name: '設定' }).click();
    });

    await test.step('設定ページに遷移することを確認する', async () => {
      await expect(page).toHaveURL(/\/setting\/edit/);
      await expect(page.getByText('飼料残量アラート')).toBeVisible();
    });
  });

  test('しきい値を変更して保存できる', async ({ page }) => {
    await test.step('設定ページにアクセスする', async () => {
      await page.goto('/setting/edit');
    });

    await test.step('しきい値に新しい値を入力する', async () => {
      await page.fill('input[name="setting[value]"]', '500');
    });

    await test.step('保存するボタンをクリックする', async () => {
      await page.click('input[type="submit"]');
    });

    await test.step('保存成功メッセージが表示されることを確認する', async () => {
      await expect(page.getByText('設定を保存しました')).toBeVisible();
    });

    await test.step('保存した値が入力欄に反映されていることを確認する', async () => {
      await expect(page.locator('input[name="setting[value]"]')).toHaveValue('500');
    });
  });

  test('無効な値を送信するとバリデーションエラーが表示される', async ({ page }) => {
    await test.step('設定ページにアクセスする', async () => {
      await page.goto('/setting/edit');
    });

    await test.step('しきい値に 0 を入力する', async () => {
      await page.fill('input[name="setting[value]"]', '0');
    });

    await test.step('保存するボタンをクリックする', async () => {
      await page.click('input[type="submit"]');
    });

    await test.step('バリデーションエラーが表示されることを確認する', async () => {
      await expect(page.locator('.field-error')).toBeVisible();
    });
  });
});
