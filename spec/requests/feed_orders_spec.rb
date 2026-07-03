require "rails_helper"

RSpec.describe "/feed_orders", type: :request do
  let(:valid_attributes) do
    { ordered_on: Date.current, quantity: 300, supplier: "JA薩摩川内", memo: "定期発注" }
  end

  let(:invalid_attributes) do
    { ordered_on: nil, quantity: nil, supplier: "" }
  end

  describe "GET /index" do
    it "200を返す" do
      create(:feed_order)
      get feed_orders_path
      expect(response).to have_http_status(:ok)
    end

    it "しきい値入力フォームを表示する" do
      get feed_orders_path
      expect(response.body).to include("アラートしきい値")
    end
  end

  describe "GET /show" do
    it "200を返す" do
      feed_order = create(:feed_order)
      get feed_order_path(feed_order)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /new" do
    it "200を返す" do
      get new_feed_order_path
      expect(response).to have_http_status(:ok)
    end

    it "直近の日次記録があるとき現在の飼料残量を表示する" do
      create(:daily_record, date: Date.current, feed_stock: 250)
      get new_feed_order_path
      expect(response.body).to include("現在の飼料残量：250kg")
    end

    it "日次記録がないとき飼料残量を表示しない" do
      DailyRecord.delete_all
      get new_feed_order_path
      expect(response.body).not_to include("現在の飼料残量")
    end
  end

  describe "GET /edit" do
    it "200を返す" do
      feed_order = create(:feed_order)
      get edit_feed_order_path(feed_order)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /create" do
    context "有効なパラメータのとき" do
      it "発注記録を1件作成する" do
        expect {
          post feed_orders_path, params: { feed_order: valid_attributes }
        }.to change(FeedOrder, :count).by(1)
      end

      it "詳細ページにリダイレクトする" do
        post feed_orders_path, params: { feed_order: valid_attributes }
        expect(response).to redirect_to(feed_order_path(FeedOrder.last))
      end
    end

    context "無効なパラメータのとき" do
      it "422を返す" do
        post feed_orders_path, params: { feed_order: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_content)
      end

      it "発注記録を作成しない" do
        expect {
          post feed_orders_path, params: { feed_order: invalid_attributes }
        }.not_to change(FeedOrder, :count)
      end
    end
  end

  describe "PATCH /update" do
    context "有効なパラメータのとき" do
      it "発注記録を更新して詳細ページにリダイレクトする" do
        feed_order = create(:feed_order)
        patch feed_order_path(feed_order), params: { feed_order: { supplier: "南九州飼料センター" } }
        expect(response).to redirect_to(feed_order_path(feed_order))
        feed_order.reload
        expect(feed_order.supplier).to eq("南九州飼料センター")
      end
    end

    context "無効なパラメータのとき" do
      it "422を返す" do
        feed_order = create(:feed_order)
        patch feed_order_path(feed_order), params: { feed_order: { supplier: "" } }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "DELETE /destroy" do
    it "発注記録を削除する" do
      feed_order = create(:feed_order)
      expect {
        delete feed_order_path(feed_order)
      }.to change(FeedOrder, :count).by(-1)
    end

    it "HTML フォーマットで一覧に 303 リダイレクトする" do
      feed_order = create(:feed_order)
      delete feed_order_path(feed_order)
      expect(response).to have_http_status(:see_other)
      expect(response).to redirect_to(feed_orders_path)
    end

    it "Turbo Stream フォーマットで 200 を返す" do
      feed_order = create(:feed_order)
      delete feed_order_path(feed_order), headers: { "Accept" => "text/vnd.turbo-stream.html" }
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /threshold" do
    context "有効な値を送信したとき" do
      it "設定を保存して一覧ページにリダイレクトする" do
        patch threshold_feed_orders_path, params: { setting: { value: 500 } }
        expect(response).to redirect_to(feed_orders_path)
        follow_redirect!
        expect(response.body).to include("アラートしきい値を保存しました")
      end

      it "DBにしきい値が保存される" do
        patch threshold_feed_orders_path, params: { setting: { value: 500 } }
        expect(Setting.feed_stock_threshold).to eq(500)
      end

      it "value 以外のパラメータは無視される（strong parameters）" do
        patch threshold_feed_orders_path, params: { setting: { value: 400, name: "tampered" } }
        expect(response).to redirect_to(feed_orders_path)
        expect(Setting.find_by(name: "tampered")).to be_nil
      end
    end

    context "無効な値を送信したとき" do
      it "422を返して一覧を再表示する" do
        patch threshold_feed_orders_path, params: { setting: { value: 0 } }
        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include("field-error")
      end

      it "DBの値が変更されないこと" do
        Setting.create!(name: Setting::FEED_STOCK_KEY, value: 300)
        patch threshold_feed_orders_path, params: { setting: { value: -1 } }
        expect(Setting.feed_stock_threshold).to eq(300)
      end
    end
  end
end
