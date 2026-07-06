# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...

## CI: bundler-audit で新しいCVEが検知された場合の対応方針

`bundle-audit check --update` は、既知の脆弱性データベースを更新した上で
`Gemfile.lock` 内のgemをチェックする。CIが赤くなった場合は以下のいずれかで対応する。

1. 脆弱性を修正したバージョンが存在する場合は、`bundle update <gem名>` で更新する
   （Dependabotが自動でPRを作成する場合はそれをマージしてもよい）
2. 修正版がまだ存在せず、影響が軽微と判断できる場合は、リポジトリ直下に
   `.bundler-audit.yml` を作成し、該当のadvisory IDを一時的にignoreする
   （対応が完了次第ignoreは削除すること）
