# 薩摩畜産日誌 プロジェクト

## 概要
薩摩畜産日誌.html をベースにした畜産管理 Web アプリケーション。
就職ポートフォリオとして、Rails + Hotwire + RSpec + Playwright の構成で開発する。

## 技術スタック

| カテゴリ | 技術 |
|---|---|
| 言語 | Ruby |
| フレームワーク | Ruby on Rails |
| フロントエンド | Hotwire（Turbo メイン、Stimulus を補助的に使用） |
| テスト | RSpec（ユニット・統合）、Playwright（E2E） |
| バージョン管理 | Git |
| デプロイ先 | AWS または GCP（予定） |

## 開発の流れ

1. Rails プロジェクト作成
2. 日誌の CRUD を ERB で作る
3. Turbo で画面遷移をスムーズにする
4. RSpec ＋ Playwright でテスト

## ディレクトリ構成

```
chikusan_app/
├── .claude/
│   ├── CLAUDE.md          # このファイル
│   └── skills/
│       └── grasp-skill-create/SKILL.md
└── docs/
    └── 薩摩畜産日誌.html  # デザイン参考ドキュメント
```

## docs について

- `docs/薩摩畜産日誌.html` はデザイン参考用のドキュメントとして保存しているだけ
- コードから読み込んだりインポートしたりしない
- あくまで UI・カラーパレットの参考として目で見るためのもの
