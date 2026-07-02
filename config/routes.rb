Rails.application.routes.draw do
  # ワクチン接種記録の CRUD ルート
  resources :vaccine_records, except: :show

  # 出荷記録の CRUD ルート（一覧・新規・登録・詳細・編集・更新・削除）
  resources :shipments

  # 飼料発注記録の CRUD ルート（一覧・新規・登録・詳細・編集・更新・削除）
  resources :feed_orders

  # 日次記録の CRUD ルート（一覧・新規・登録・詳細・編集・更新・削除）
  resources :daily_records

  # /up にアクセスするとアプリの起動状態を確認できる（ロードバランサー等の死活監視用）
  get "up" => "rails/health#show", as: :rails_health_check

  # PWA 用のファイルを動的に生成するルート
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  get "report" => "reports#index", as: :report

  resource :setting, only: %i[edit update]

  # 畜種マスタの CRUD ルート
  resources :livestock_types

  root "home#index"
end
