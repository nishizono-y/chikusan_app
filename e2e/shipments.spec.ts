import { test, expect } from '@playwright/test';

test.describe('出荷記録', () => {
  test('一覧ページが表示される', async ({ page }) => {
    await test.step('出荷記録の一覧ページにアクセスする', async () => {
      await page.goto('/shipments');
    });

    await test.step('ページタイトルが「出荷記録一覧」であることを確認する', async () => {
      await expect(page).toHaveTitle(/出荷記録一覧/);
      await expect(page.getByText('出荷記録一覧')).toBeVisible();
    });
  });

  test('新規作成して一覧に反映される', async ({ page }) => {
    await test.step('新規作成ページにアクセスする', async () => {
      await page.goto('/shipments/new');
    });

    await test.step('出荷日を入力する', async () => {
      await page.fill('input[name="shipment[shipped_at]"]', '2026-06-23');
    });

    await test.step('出荷頭数を入力する', async () => {
      await page.fill('input[name="shipment[count]"]', '10');
    });

    await test.step('平均体重を入力する', async () => {
      await page.fill('input[name="shipment[avg_weight]"]', '110.5');
    });

    await test.step('出荷先を入力する', async () => {
      await page.fill('input[name="shipment[destination]"]', '鹿児島食肉センター');
    });

    await test.step('登録するボタンをクリックする', async () => {
      await page.click('input[type="submit"]');
    });

    await test.step('登録した内容が詳細画面に表示されることを確認する', async () => {
      await expect(page.getByText('10', { exact: true })).toBeVisible();
      await expect(page.getByText('鹿児島食肉センター')).toBeVisible();
    });
  });

  test('登録したデータを編集できる', async ({ page }) => {
    await test.step('出荷記録の一覧ページにアクセスする', async () => {
      await page.goto('/shipments');
    });

    await test.step('最初のレコードの詳細ページに移動する', async () => {
      await page.getByText('詳細').first().click();
    });

    await test.step('編集ボタンをクリックする', async () => {
      await page.getByText('編集').click();
    });

    await test.step('出荷先を更新する', async () => {
      await page.fill('input[name="shipment[destination]"]', '南九州市場');
    });

    await test.step('更新するボタンをクリックする', async () => {
      await page.click('input[type="submit"]');
    });

    await test.step('更新した内容が詳細画面に反映されることを確認する', async () => {
      await expect(page.getByText('南九州市場')).toBeVisible();
    });
  });

  test('登録したデータを削除できる', async ({ page }) => {
    await test.step('出荷記録の一覧ページにアクセスする', async () => {
      await page.goto('/shipments');
    });

    await test.step('最初のレコードの詳細ページに移動する', async () => {
      await page.getByText('詳細').first().click();
    });

    await test.step('削除ボタンをクリックして確認ダイアログを承認する', async () => {
      page.once('dialog', (dialog) => dialog.accept());
      await page.getByText('削除').click();
    });

    await test.step('一覧ページに戻り、削除されたレコードがないことを確認する', async () => {
      await expect(page).toHaveURL(/\/shipments/);
      await expect(page.getByText('出荷記録一覧')).toBeVisible();
    });
  });
});
