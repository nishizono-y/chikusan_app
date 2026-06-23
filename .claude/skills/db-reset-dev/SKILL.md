---
name: db-reset-dev
description: >
  開発用またはテスト用の DB をリセットしたいとき。
  「DB をリセットして」「データを初期化したい」「シードを入れ直して」
  「E2E テストの前に DB をきれいにしたい」と言われたときにトリガーする。
---

# db-reset-dev

開発・E2E テスト前の DB リセットをまとめて実行する。
リセット対象（開発用 / テスト用）をまず確認してから実行すること。

---

## DB の種類と使い分け

| 対象 | ファイル | 用途 |
|---|---|---|
| 開発用 | `storage/development.sqlite3` | ブラウザで動作確認するとき |
| テスト用 | `storage/test.sqlite3` | RSpec・Playwright を実行するとき |

---

## 開発用 DB をリセットする

```bash
bin/rails db:reset
```

`db:drop` → `db:create` → `db:schema:load` → `db:seed` を一括実行する。
シードデータ（`db/seeds.rb`）が投入されるので、ブラウザで動作確認できる状態になる。

---

## テスト用 DB をリセットする

RSpec 用：

```bash
RAILS_ENV=test bin/rails db:reset
```

Playwright 用は **手動リセット不要**。
`npx playwright test` を実行すると `bin/test-server` が自動的に以下を実行してからサーバーを起動する：

```
db:drop → db:create → db:schema:load → db:seed
```

---

## シードデータの内容

`db/seeds.rb` で以下のデータが投入される（`find_or_create_by!` なので重複投入は安全）：

- 日次記録: 2026-06-01、2026-06-02 の 2件
- 出荷記録: 2026-06-10 の 1件

---

## 注意点

- `db:reset` は **drop（削除）から始まる破壊的操作**。実行前に対象環境（development / test）を必ず確認する
- 開発用とテスト用は別ファイルなので、片方をリセットしてももう片方には影響しない
- `bin/test-server` は Playwright 専用。RSpec は別途 `RAILS_ENV=test bin/rails db:reset` が必要
- マイグレーションが増えた後は `db:schema:load` ではなく `db:migrate` で差分適用できる（リセット不要な場合）
