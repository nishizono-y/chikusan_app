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
end
