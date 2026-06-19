import { test, expect } from '@playwright/test';

test.describe('日次記録', () => {
  test('一覧ページが表示される', async ({ page }) => {
    await test.step('日次記録の一覧ページにアクセスする', async () => {
      await page.goto('/daily_records');
    });

    await test.step('ページタイトルが「日次記録一覧」であることを確認する', async () => {
      await expect(page).toHaveTitle(/日次記録一覧/);
      await expect(page.getByText('日次記録一覧')).toBeVisible();
    });
  });

  test('新規作成して一覧に反映される', async ({ page }) => {
    await test.step('新規作成ページにアクセスする', async () => {
      await page.goto('/daily_records/new');
    });

    await test.step('日付を入力する', async () => {
      await page.fill('input[name="daily_record[date]"]', '2026-06-18');
    });

    await test.step('死亡頭数を入力する', async () => {
      await page.fill('input[name="daily_record[death_count]"]', '0');
    });

    await test.step('飼料使用量を入力する', async () => {
      await page.fill('input[name="daily_record[feed_usage]"]', '130');
    });

    await test.step('飼料残量を入力する', async () => {
      await page.fill('input[name="daily_record[feed_stock]"]', '380');
    });

    await test.step('ワクチン接種を選択する', async () => {
      await page.selectOption('select[name="daily_record[vaccine]"]', 'なし');
    });

    await test.step('メモを入力する', async () => {
      await page.fill('textarea[name="daily_record[memo]"]', 'テスト用メモ');
    });

    await test.step('登録するボタンをクリックする', async () => {
      await page.click('input[type="submit"]');
    });

    await test.step('登録した内容が詳細画面に表示されることを確認する', async () => {
      await expect(page.getByText('130')).toBeVisible();
      await expect(page.getByText('テスト用メモ')).toBeVisible();
    });
  });

  test('登録したデータを編集できる', async ({ page }) => {
    await test.step('日次記録の一覧ページにアクセスする', async () => {
      await page.goto('/daily_records');
    });

    await test.step('最初のレコードの詳細ページに移動する', async () => {
      await page.getByText('詳細').first().click();
    });

    await test.step('編集ボタンをクリックする', async () => {
      await page.getByText('編集').click();
    });

    await test.step('メモを更新する', async () => {
      await page.fill('textarea[name="daily_record[memo]"]', '更新したメモ');
    });

    await test.step('更新するボタンをクリックする', async () => {
      await page.click('input[type="submit"]');
    });

    await test.step('更新した内容が詳細画面に反映されることを確認する', async () => {
      await expect(page.getByText('更新したメモ')).toBeVisible();
    });
  });
});
