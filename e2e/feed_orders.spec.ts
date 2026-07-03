import { test, expect } from '@playwright/test';

test.describe('飼料発注記録', () => {
  test('一覧ページが表示される', async ({ page }) => {
    await test.step('発注履歴の一覧ページにアクセスする', async () => {
      await page.goto('/feed_orders');
    });

    await test.step('ページタイトルが「発注履歴一覧」であることを確認する', async () => {
      await expect(page).toHaveTitle(/発注履歴一覧/);
      await expect(page.getByText('発注履歴一覧')).toBeVisible();
    });
  });

  test('直近の日次記録があるとき現在の飼料残量が参考表示される', async ({ page }) => {
    await test.step('日次記録を1件登録する', async () => {
      await page.goto('/daily_records/new');
      await page.fill('input[name="daily_record[date]"]', '2026-07-02');
      await page.fill('input[name="daily_record[head_count]"]', '100');
      await page.fill('input[name="daily_record[death_count]"]', '0');
      await page.fill('input[name="daily_record[feed_usage]"]', '20');
      await page.fill('input[name="daily_record[feed_stock]"]', '380');
      await page.click('input[type="submit"]');
    });

    await test.step('発注記録の新規作成ページにアクセスする', async () => {
      await page.goto('/feed_orders/new');
    });

    await test.step('現在の飼料残量が表示されることを確認する', async () => {
      await expect(page.getByText('現在の飼料残量：380kg')).toBeVisible();
    });
  });

  test('新規作成して一覧に反映される', async ({ page }) => {
    await test.step('新規作成ページにアクセスする', async () => {
      await page.goto('/feed_orders/new');
    });

    await test.step('発注日を入力する', async () => {
      await page.fill('input[name="feed_order[ordered_on]"]', '2026-07-02');
    });

    await test.step('数量を入力する', async () => {
      await page.fill('input[name="feed_order[quantity]"]', '300');
    });

    await test.step('発注先を入力する', async () => {
      await page.fill('input[name="feed_order[supplier]"]', 'JA薩摩川内');
    });

    await test.step('登録するボタンをクリックする', async () => {
      await page.click('input[type="submit"]');
    });

    await test.step('登録した内容が詳細画面に表示されることを確認する', async () => {
      await expect(page.getByText('300', { exact: true })).toBeVisible();
      await expect(page.getByText('JA薩摩川内')).toBeVisible();
    });
  });

  test('登録したデータを編集できる', async ({ page }) => {
    await test.step('発注履歴の一覧ページにアクセスする', async () => {
      await page.goto('/feed_orders');
    });

    await test.step('最初のレコードの詳細ページに移動する', async () => {
      await page.getByText('詳細').first().click();
    });

    await test.step('編集ボタンをクリックする', async () => {
      await page.getByText('編集').click();
    });

    await test.step('発注先を更新する', async () => {
      await page.fill('input[name="feed_order[supplier]"]', '南九州飼料センター');
    });

    await test.step('更新するボタンをクリックする', async () => {
      await page.click('input[type="submit"]');
    });

    await test.step('更新した内容が詳細画面に反映されることを確認する', async () => {
      await expect(page.getByText('南九州飼料センター')).toBeVisible();
    });
  });

  test('登録したデータを削除できる', async ({ page }) => {
    await test.step('発注履歴の一覧ページにアクセスする', async () => {
      await page.goto('/feed_orders');
    });

    await test.step('最初のレコードの詳細ページに移動する', async () => {
      await page.getByText('詳細').first().click();
    });

    await test.step('削除ボタンをクリックして確認ダイアログを承認する', async () => {
      page.once('dialog', (dialog) => dialog.accept());
      await page.getByText('削除').click();
    });

    await test.step('一覧ページに戻り、削除されたレコードがないことを確認する', async () => {
      await expect(page).toHaveURL(/\/feed_orders/);
      await expect(page.getByText('発注履歴一覧')).toBeVisible();
    });
  });

  test('アラートしきい値を変更して保存できる', async ({ page }) => {
    await test.step('発注履歴の一覧ページにアクセスする', async () => {
      await page.goto('/feed_orders');
    });

    await test.step('飼料残量アラートのアコーディオンを開く', async () => {
      await page.click('summary.card-title');
    });

    await test.step('しきい値に新しい値を入力する', async () => {
      await page.fill('input[name="setting[value]"]', '500');
    });

    await test.step('保存するボタンをクリックする', async () => {
      await page.click('input[type="submit"]');
    });

    await test.step('保存成功メッセージが表示されることを確認する', async () => {
      await expect(page.getByText('アラートしきい値を保存しました')).toBeVisible();
    });

    await test.step('保存した値が入力欄に反映されていることを確認する', async () => {
      await expect(page.locator('input[name="setting[value]"]')).toHaveValue('500');
    });
  });

  test('しきい値に無効な値を送信するとバリデーションエラーが表示される', async ({ page }) => {
    await test.step('発注履歴の一覧ページにアクセスする', async () => {
      await page.goto('/feed_orders');
    });

    await test.step('飼料残量アラートのアコーディオンを開く', async () => {
      await page.click('summary.card-title');
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
