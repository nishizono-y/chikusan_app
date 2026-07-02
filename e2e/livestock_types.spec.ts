import { test, expect } from '@playwright/test';

test.describe('畜種', () => {
  test('一覧ページが表示される', async ({ page }) => {
    await test.step('畜種の一覧ページにアクセスする', async () => {
      await page.goto('/livestock_types');
    });

    await test.step('ページタイトルが「畜種一覧」であることを確認する', async () => {
      await expect(page).toHaveTitle(/畜種一覧/);
      await expect(page.getByText('畜種一覧')).toBeVisible();
    });
  });

  test('日次記録一覧に戻るリンクから遷移できる', async ({ page }) => {
    await test.step('畜種の一覧ページにアクセスする', async () => {
      await page.goto('/livestock_types');
    });

    await test.step('日次記録一覧に戻るリンクをクリックする', async () => {
      await page.getByText('日次記録一覧に戻る').click();
    });

    await test.step('日次記録一覧ページに遷移することを確認する', async () => {
      await expect(page).toHaveURL(/\/daily_records/);
      await expect(page.getByText('日次記録一覧')).toBeVisible();
    });
  });

  test('新規作成して一覧に反映される', async ({ page }) => {
    await test.step('新規作成ページにアクセスする', async () => {
      await page.goto('/livestock_types/new');
    });

    await test.step('畜種名を入力する', async () => {
      await page.fill('input[name="livestock_type[name]"]', '肉用牛');
    });

    await test.step('単位を入力する', async () => {
      await page.fill('input[name="livestock_type[unit]"]', '頭');
    });

    await test.step('登録するボタンをクリックする', async () => {
      await page.click('input[type="submit"]');
    });

    await test.step('登録した内容が詳細画面に表示されることを確認する', async () => {
      await expect(page.getByText('肉用牛')).toBeVisible();
      await expect(page.getByText('頭', { exact: true })).toBeVisible();
    });
  });

  test('登録したデータを編集できる', async ({ page }) => {
    await test.step('編集対象の畜種を登録しておく', async () => {
      await page.goto('/livestock_types/new');
      await page.fill('input[name="livestock_type[name]"]', 'テスト牛(更新前)');
      await page.fill('input[name="livestock_type[unit]"]', '頭');
      await page.click('input[type="submit"]');
    });

    await test.step('編集ボタンをクリックする', async () => {
      await page.getByText('編集').click();
    });

    await test.step('畜種名を更新する', async () => {
      await page.fill('input[name="livestock_type[name]"]', '採卵鶏');
    });

    await test.step('単位を更新する', async () => {
      await page.fill('input[name="livestock_type[unit]"]', '羽');
    });

    await test.step('更新するボタンをクリックする', async () => {
      await page.click('input[type="submit"]');
    });

    await test.step('更新した内容が詳細画面に反映されることを確認する', async () => {
      await expect(page.getByText('採卵鶏')).toBeVisible();
      await expect(page.getByText('羽', { exact: true })).toBeVisible();
    });
  });

  test('登録したデータを削除できる', async ({ page }) => {
    await test.step('削除対象の畜種を登録しておく', async () => {
      await page.goto('/livestock_types/new');
      await page.fill('input[name="livestock_type[name]"]', 'テスト牛(消去対象)');
      await page.fill('input[name="livestock_type[unit]"]', '頭');
      await page.click('input[type="submit"]');
    });

    await test.step('削除ボタンをクリックして確認ダイアログを承認する', async () => {
      page.once('dialog', (dialog) => dialog.accept());
      await page.getByText('削除').click();
    });

    await test.step('一覧ページに戻ることを確認する', async () => {
      await expect(page).toHaveURL(/\/livestock_types/);
      await expect(page.getByText('畜種一覧')).toBeVisible();
    });
  });
});
