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

  test('畜種管理リンクから畜種一覧へ遷移できる', async ({ page }) => {
    await test.step('日次記録の一覧ページにアクセスする', async () => {
      await page.goto('/daily_records');
    });

    await test.step('畜種管理アイコンをクリックする', async () => {
      await page.locator('a[title="畜種管理"]').click();
    });

    await test.step('畜種一覧ページに遷移することを確認する', async () => {
      await expect(page).toHaveURL(/\/livestock_types/);
      await expect(page.getByText('畜種一覧')).toBeVisible();
    });
  });

  test('新規作成して一覧に反映される', async ({ page }) => {
    await test.step('新規作成ページにアクセスする', async () => {
      await page.goto('/daily_records/new');
    });

    await test.step('日付を入力する', async () => {
      await page.fill('input[name="daily_record[date]"]', '2026-06-18');
    });

    await test.step('飼養頭数を入力する', async () => {
      await page.fill('input[name="daily_record[head_count]"]', '50');
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

  test('畜種を選択して登録できる', async ({ page }) => {
    await test.step('畜種を登録しておく', async () => {
      await page.goto('/livestock_types/new');
      await page.fill('input[name="livestock_type[name]"]', '肉用牛(登録テスト)');
      await page.fill('input[name="livestock_type[unit]"]', '頭');
      await page.click('input[type="submit"]');
    });

    await test.step('新規作成ページにアクセスする', async () => {
      await page.goto('/daily_records/new');
    });

    await test.step('日付を入力する', async () => {
      await page.fill('input[name="daily_record[date]"]', '2026-06-20');
    });

    await test.step('畜種を選択する', async () => {
      await page.selectOption('select[name="daily_record[livestock_type_id]"]', { label: '肉用牛(登録テスト)' });
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

    await test.step('登録するボタンをクリックする', async () => {
      await page.click('input[type="submit"]');
    });

    await test.step('選択した畜種が詳細画面に表示されることを確認する', async () => {
      await expect(page.getByText('肉用牛(登録テスト)')).toBeVisible();
    });
  });

  test('畜種を選択すると飼養頭数に単位が表示される', async ({ page }) => {
    await test.step('単位の異なる畜種を2件登録しておく', async () => {
      await page.goto('/livestock_types/new');
      await page.fill('input[name="livestock_type[name]"]', '肉用牛(単位テスト)');
      await page.fill('input[name="livestock_type[unit]"]', '頭');
      await page.click('input[type="submit"]');

      await page.goto('/livestock_types/new');
      await page.fill('input[name="livestock_type[name]"]', '採卵鶏(単位テスト)');
      await page.fill('input[name="livestock_type[unit]"]', '羽');
      await page.click('input[type="submit"]');
    });

    await test.step('新規作成ページにアクセスする', async () => {
      await page.goto('/daily_records/new');
    });

    await test.step('畜種未選択のときは単位が表示されない', async () => {
      await page.selectOption('select[name="daily_record[livestock_type_id]"]', '');
      await expect(page.getByText('飼養頭数', { exact: true })).toBeVisible();
      await expect(page.getByText('死亡頭数', { exact: true })).toBeVisible();
    });

    await test.step('「採卵鶏(単位テスト)」を選択すると単位が「羽」になる', async () => {
      await page.selectOption('select[name="daily_record[livestock_type_id]"]', { label: '採卵鶏(単位テスト)' });
      await expect(page.getByText('飼養頭数（羽）')).toBeVisible();
      await expect(page.getByText('死亡頭数（羽）')).toBeVisible();
    });

    await test.step('「肉用牛(単位テスト)」を選択すると単位が「頭」になる', async () => {
      await page.selectOption('select[name="daily_record[livestock_type_id]"]', { label: '肉用牛(単位テスト)' });
      await expect(page.getByText('飼養頭数（頭）')).toBeVisible();
      await expect(page.getByText('死亡頭数（頭）')).toBeVisible();
    });
  });

  test('登録したデータを編集できる', async ({ page }) => {
    await test.step('日次記録の一覧ページにアクセスする', async () => {
      await page.goto('/daily_records?month=2026-06');
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
