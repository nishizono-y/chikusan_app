import { test, expect } from '@playwright/test';
import * as fs from 'fs';
import * as path from 'path';

const SCREENSHOT_DIR = path.join(__dirname, '../test-results/screenshots');
const RESULT_JSON    = path.join(__dirname, '../test-results/results.json');

const results: { no: number; name: string; status: string; screenshots: string[] }[] = [];

test.beforeAll(() => {
  fs.mkdirSync(SCREENSHOT_DIR, { recursive: true });
});

test.afterAll(() => {
  fs.writeFileSync(RESULT_JSON, JSON.stringify(results, null, 2));
});

// No.1 一覧ページが表示される
test('No.1 一覧ページが表示される', async ({ page }) => {
  const shots: string[] = [];
  let status = 'OK';

  try {
    await test.step('日次記録の一覧ページにアクセスする', async () => {
      await page.goto('/daily_records');
      const p = path.join(SCREENSHOT_DIR, '01_step1_一覧アクセス.png');
      await page.screenshot({ path: p, fullPage: true });
      shots.push(p);
    });

    await test.step('ページタイトルが「日次記録一覧」であることを確認する', async () => {
      await expect(page.getByText('日次記録一覧')).toBeVisible();
      const p = path.join(SCREENSHOT_DIR, '01_step2_タイトル確認.png');
      await page.screenshot({ path: p, fullPage: true });
      shots.push(p);
    });
  } catch {
    status = 'NG';
  }

  results.push({ no: 1, name: '一覧ページが表示される', status, screenshots: shots });
});

// No.2 新規作成して一覧に反映される
test('No.2 新規作成して一覧に反映される', async ({ page }) => {
  const shots: string[] = [];
  let status = 'OK';

  try {
    await test.step('新規作成ページにアクセスする', async () => {
      await page.goto('/daily_records/new');
      const p = path.join(SCREENSHOT_DIR, '02_step1_新規作成アクセス.png');
      await page.screenshot({ path: p, fullPage: true });
      shots.push(p);
    });

    await test.step('フォームに入力する', async () => {
      await page.fill('input[name="daily_record[date]"]', '2026-06-19');
      await page.fill('input[name="daily_record[death_count]"]', '0');
      await page.fill('input[name="daily_record[feed_usage]"]', '130');
      await page.fill('input[name="daily_record[feed_stock]"]', '380');
      await page.selectOption('select[name="daily_record[vaccine]"]', 'なし');
      await page.fill('textarea[name="daily_record[memo]"]', 'テスト用メモ');
      const p = path.join(SCREENSHOT_DIR, '02_step2_フォーム入力.png');
      await page.screenshot({ path: p, fullPage: true });
      shots.push(p);
    });

    await test.step('登録するボタンをクリックする', async () => {
      await page.click('input[type="submit"]');
      await page.waitForURL(/daily_records\/\d+/);
      const p = path.join(SCREENSHOT_DIR, '02_step3_登録後詳細.png');
      await page.screenshot({ path: p, fullPage: true });
      shots.push(p);
    });

    await test.step('登録した内容が表示されることを確認する', async () => {
      await expect(page.getByText('130')).toBeVisible();
      await expect(page.getByText('テスト用メモ')).toBeVisible();
      const p = path.join(SCREENSHOT_DIR, '02_step4_内容確認.png');
      await page.screenshot({ path: p, fullPage: true });
      shots.push(p);
    });
  } catch {
    status = 'NG';
  }

  results.push({ no: 2, name: '新規作成して一覧に反映される', status, screenshots: shots });
});

// No.3 登録したデータを編集できる
test('No.3 登録したデータを編集できる', async ({ page }) => {
  const shots: string[] = [];
  let status = 'OK';

  try {
    await test.step('日次記録の一覧ページにアクセスする', async () => {
      await page.goto('/daily_records');
      const p = path.join(SCREENSHOT_DIR, '03_step1_一覧アクセス.png');
      await page.screenshot({ path: p, fullPage: true });
      shots.push(p);
    });

    await test.step('最初のレコードの詳細ページに移動する', async () => {
      await page.getByText('詳細').first().click();
      const p = path.join(SCREENSHOT_DIR, '03_step2_詳細ページ.png');
      await page.screenshot({ path: p, fullPage: true });
      shots.push(p);
    });

    await test.step('編集ボタンをクリックする', async () => {
      await page.getByText('編集').click();
      const p = path.join(SCREENSHOT_DIR, '03_step3_編集ページ.png');
      await page.screenshot({ path: p, fullPage: true });
      shots.push(p);
    });

    await test.step('メモを更新して保存する', async () => {
      await page.fill('textarea[name="daily_record[memo]"]', '更新したメモ');
      await page.click('input[type="submit"]');
      await page.waitForURL(/daily_records\/\d+/);
      const p = path.join(SCREENSHOT_DIR, '03_step4_更新後詳細.png');
      await page.screenshot({ path: p, fullPage: true });
      shots.push(p);
    });

    await test.step('更新した内容が表示されることを確認する', async () => {
      await expect(page.getByText('更新したメモ')).toBeVisible();
      const p = path.join(SCREENSHOT_DIR, '03_step5_内容確認.png');
      await page.screenshot({ path: p, fullPage: true });
      shots.push(p);
    });
  } catch {
    status = 'NG';
  }

  results.push({ no: 3, name: '登録したデータを編集できる', status, screenshots: shots });
});
