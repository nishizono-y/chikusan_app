---
name: test-suite
description: >
  RSpec と Playwright を両方実行して結果をまとめて報告するスキル。
  「テスト全部通る？」「テスト実行して」「E2E と RSpec まとめて確認したい」
  と言われたときにトリガーする。
---

# test-suite

RSpec（ユニット・統合）と Playwright（E2E）を順番に実行し、
失敗箇所を日本語でまとめて報告する。

## 実行手順

### Step 1: RSpec を実行する

```bash
bundle exec rspec
```

- `spec/models/` — モデルのバリデーション検証
- `spec/requests/` — コントローラのHTTPレスポンス検証

### Step 2: Playwright を実行する

```bash
npx playwright test
```

- `e2e/` 配下のすべてのテストが対象
- Playwright は実行時に `bin/test-server` を自動起動してテスト用 DB を初期化するため、事前準備は不要

## 結果の報告フォーマット

実行後、以下の形式で日本語にまとめて報告する：

```
## テスト結果サマリー

### RSpec
- 結果: ✅ 全件パス / ❌ X件失敗
- 失敗したテスト:（あれば列挙）
  - `spec/models/daily_record_spec.rb` — 〇〇のバリデーションが通っていない

### Playwright
- 結果: ✅ 全件パス / ❌ X件失敗
- 失敗したテスト:（あれば列挙）
  - `e2e/daily_records.spec.ts` — 削除後のフラッシュメッセージが表示されない

### 総評
（全体として何が問題か、次に何をすべきかを1〜2行で）
```

## 注意点

- Playwright は `bin/test-server` でテスト用 DB（ポート 3001）を毎回作り直すため、時間がかかる（初回 30 秒程度）
- RSpec と Playwright は別の DB（`test` 環境）を使うが、Playwright 側は `bin/test-server` がリセットする
- 失敗時のスクリーンショットは `test-results/` に、動画は `playwright-report/` に保存される
