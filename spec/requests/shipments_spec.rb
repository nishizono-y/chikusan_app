require "rails_helper"

RSpec.describe "/shipments", type: :request do
  let(:valid_attributes) do
    attributes_for(:shipment)
  end

  let(:invalid_attributes) do
    { shipped_at: nil, count: nil, avg_weight: nil, destination: "" }
  end

  describe "GET /index" do
    it "200を返す" do
      create(:shipment)
      get shipments_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /show" do
    it "200を返す" do
      shipment = create(:shipment)
      get shipment_path(shipment)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /new" do
    it "200を返す" do
      get new_shipment_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /edit" do
    it "200を返す" do
      shipment = create(:shipment)
      get edit_shipment_path(shipment)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /create" do
    context "有効なパラメータのとき" do
      it "出荷記録を1件作成する" do
        expect {
          post shipments_path, params: { shipment: valid_attributes }
        }.to change(Shipment, :count).by(1)
      end

      it "詳細ページにリダイレクトする" do
        post shipments_path, params: { shipment: valid_attributes }
        expect(response).to redirect_to(shipment_path(Shipment.last))
      end
    end

    context "無効なパラメータのとき" do
      it "422を返す" do
        post shipments_path, params: { shipment: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_content)
      end

      it "出荷記録を作成しない" do
        expect {
          post shipments_path, params: { shipment: invalid_attributes }
        }.not_to change(Shipment, :count)
      end
    end
  end

  describe "PATCH /update" do
    context "有効なパラメータのとき" do
      it "出荷記録を更新して詳細ページにリダイレクトする" do
        shipment = create(:shipment)
        patch shipment_path(shipment), params: { shipment: { destination: "宮崎食肉センター" } }
        expect(response).to redirect_to(shipment_path(shipment))
        shipment.reload
        expect(shipment.destination).to eq("宮崎食肉センター")
      end
    end

    context "無効なパラメータのとき" do
      it "422を返す" do
        shipment = create(:shipment)
        patch shipment_path(shipment), params: { shipment: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "DELETE /destroy" do
    it "出荷記録を削除して303で一覧にリダイレクトする" do
      shipment = create(:shipment)
      expect {
        delete shipment_path(shipment)
      }.to change(Shipment, :count).by(-1)
      expect(response).to have_http_status(:see_other)
      expect(response).to redirect_to(shipments_path)
    end
  end
end
