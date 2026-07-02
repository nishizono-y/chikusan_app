require "rails_helper"

RSpec.describe "/livestock_types", type: :request do
  let(:valid_attributes) do
    { name: "肉用牛", unit: "頭" }
  end

  let(:invalid_attributes) do
    { name: "", unit: "" }
  end

  describe "GET /index" do
    it "200を返す" do
      create(:livestock_type)
      get livestock_types_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /show" do
    it "200を返す" do
      livestock_type = create(:livestock_type)
      get livestock_type_path(livestock_type)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /new" do
    it "200を返す" do
      get new_livestock_type_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /edit" do
    it "200を返す" do
      livestock_type = create(:livestock_type)
      get edit_livestock_type_path(livestock_type)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /create" do
    context "有効なパラメータのとき" do
      it "畜種を1件作成する" do
        expect {
          post livestock_types_path, params: { livestock_type: valid_attributes }
        }.to change(LivestockType, :count).by(1)
      end

      it "詳細ページにリダイレクトする" do
        post livestock_types_path, params: { livestock_type: valid_attributes }
        expect(response).to redirect_to(livestock_type_path(LivestockType.last))
      end
    end

    context "無効なパラメータのとき" do
      it "422を返す" do
        post livestock_types_path, params: { livestock_type: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_content)
      end

      it "畜種を作成しない" do
        expect {
          post livestock_types_path, params: { livestock_type: invalid_attributes }
        }.not_to change(LivestockType, :count)
      end
    end
  end

  describe "PATCH /update" do
    context "有効なパラメータのとき" do
      it "畜種を更新して詳細ページにリダイレクトする" do
        livestock_type = create(:livestock_type)
        patch livestock_type_path(livestock_type), params: { livestock_type: { name: "採卵鶏", unit: "羽" } }
        expect(response).to redirect_to(livestock_type_path(livestock_type))
        livestock_type.reload
        expect(livestock_type.name).to eq("採卵鶏")
        expect(livestock_type.unit).to eq("羽")
      end
    end

    context "無効なパラメータのとき" do
      it "422を返す" do
        livestock_type = create(:livestock_type)
        patch livestock_type_path(livestock_type), params: { livestock_type: { name: "" } }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "DELETE /destroy" do
    it "畜種を削除する" do
      livestock_type = create(:livestock_type)
      expect {
        delete livestock_type_path(livestock_type)
      }.to change(LivestockType, :count).by(-1)
    end

    it "HTML フォーマットで一覧に 303 リダイレクトする" do
      livestock_type = create(:livestock_type)
      delete livestock_type_path(livestock_type)
      expect(response).to have_http_status(:see_other)
      expect(response).to redirect_to(livestock_types_path)
    end

    it "Turbo Stream フォーマットで 200 を返す" do
      livestock_type = create(:livestock_type)
      delete livestock_type_path(livestock_type), headers: { "Accept" => "text/vnd.turbo-stream.html" }
      expect(response).to have_http_status(:ok)
    end

    it "関連する日次記録がある場合は削除できない" do
      livestock_type = create(:livestock_type)
      create(:daily_record, livestock_type: livestock_type)

      expect {
        delete livestock_type_path(livestock_type)
      }.not_to change(LivestockType, :count)
      expect(response).to redirect_to(livestock_types_path)
    end
  end
end
