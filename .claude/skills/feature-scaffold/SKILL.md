---
name: feature-scaffold
description: >
  新しいモデルの CRUD 機能を追加するとき、必要なファイル群をまとめて生成するスキル。
  「〇〇モデルを追加して」「〇〇の CRUD を作って」「新しい機能のたたき台を作りたい」
  と言われたときにトリガーする。
---

# feature-scaffold

モデル名とカラム情報をユーザーから受け取り、このプロジェクトの規約に沿って
必要なファイルをまとめて生成する。

---

## 事前確認（ユーザーに聞くこと）

生成前に以下を確認する：

1. **モデル名**（例: `Livestock`、`MedicalRecord`）
2. **カラムと型**（例: `name:string`, `birth_date:date`, `weight:decimal`）
3. **日本語の表示名**（例: 「家畜」「診療記録」）— ビューとテストで使う

---

## 生成手順

### Step 1: マイグレーション＋モデル生成

```bash
bin/rails generate model <ModelName> <columns>
bin/rails db:migrate
```

### Step 2: コントローラ生成

```bash
bin/rails generate controller <ModelName>s index show new edit
```

### Step 3: ルーティング追加

`config/routes.rb` に追加：

```ruby
resources :<model_names>
```

### Step 4: 各ファイルをプロジェクト規約に合わせて編集

生成後に以下を手動で整える（scaffold のデフォルトとこのプロジェクトの規約が異なるため）：

#### モデル
- バリデーションを追加する（`presence: true`、`numericality` など）
- 定数（選択肢リスト）は `FREEZE` で定義する（`DailyRecord::VACCINE_OPTIONS` が参考）

#### コントローラ
- `respond_to` で `format.html` / `format.turbo_stream` / `format.json` を明示する
- `destroy` アクションは `format.turbo_stream` を最初に書く（削除は Turbo Stream で差分更新するため）
- Strong Parameters を `private` に定義する

#### ビュー
- `index.html.erb`: テーブル形式、`id="<model_names>"` を `tbody` に付ける、`dom_id` で各行に ID を付ける
- `_<model>.html.erb`: `id="<%= dom_id <model> %>"` を付けた `div` で囲む
- `destroy.turbo_stream.erb`: 削除後に該当行を DOM から除去 + flash を表示する
- `shared/_flash.html.erb` は共通パーシャルとして存在するので流用する

#### FactoryBot
`spec/factories/<model_names>.rb` を作成する（RSpec で使用）：

```ruby
FactoryBot.define do
  factory :<model_name> do
    # 有効なデフォルト値を設定する
  end
end
```

---

## 生成するファイル一覧

| ファイル | 内容 |
|---|---|
| `db/migrate/XXXXXX_create_<model_names>.rb` | マイグレーション |
| `app/models/<model_name>.rb` | モデル + バリデーション |
| `app/controllers/<model_names>_controller.rb` | CRUD コントローラ |
| `app/views/<model_names>/index.html.erb` | 一覧 |
| `app/views/<model_names>/show.html.erb` | 詳細 |
| `app/views/<model_names>/new.html.erb` | 新規作成フォーム |
| `app/views/<model_names>/edit.html.erb` | 編集フォーム |
| `app/views/<model_names>/_form.html.erb` | フォームパーシャル |
| `app/views/<model_names>/_<model_name>.html.erb` | 表示パーシャル |
| `app/views/<model_names>/destroy.turbo_stream.erb` | 削除時の Turbo Stream |
| `spec/models/<model_name>_spec.rb` | モデルの RSpec |
| `spec/requests/<model_names>_spec.rb` | リクエストの RSpec |
| `spec/factories/<model_names>.rb` | FactoryBot |
| `e2e/<model_names>.spec.ts` | Playwright E2E テスト |

---

## RSpec の規約

### モデルスペック（`spec/models/<model_name>_spec.rb`）
- `subject { build(:<model_name>) }` を使う
- `describe 'バリデーション'` ブロックでカラムごとにテストを書く
- 日本語でテスト名を書く（例: `it '必須である'`）

### リクエストスペック（`spec/requests/<model_names>_spec.rb`）
- `let(:valid_attributes)` と `let(:invalid_attributes)` を定義する
- `FactoryBot.create(:<model_name>)` を使う（`Model.create!` は使わない）

---

## Playwright E2E の規約

- `test.describe('日本語のモデル名', () => {})` でグループ化する
- `test.step()` で操作を細かく分割して可読性を上げる
- 入力フィールドは `input[name="<model>[<column>]"]` 形式でセレクタを指定する
- テストケースは最低限「一覧表示」「新規作成」「編集」「削除」の4つを書く
- 削除テストでは Turbo Stream による DOM 更新（ページ遷移なし）を前提とする

---

## 注意点

- `bin/rails generate scaffold` は**使わない**。ビューのスタイルがこのプロジェクトの規約と合わないため、モデルとコントローラを別々に生成して手動で整える
- 削除は Turbo Stream で行うため、`destroy.turbo_stream.erb` は必ず作成する
- モデル間のアソシエーションが必要になった場合は `grasp-architecture` スキルで設計方針を確認してから追加する
