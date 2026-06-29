require "rails_helper"

RSpec.describe "/vaccine_records", type: :request do
  let(:valid_attributes) do
    { vaccine_name: "FMD vaccine", vaccinated_on: Date.current - 30, head_count: 50, next_due_on: Date.current + 60 }
  end

  let(:invalid_attributes) do
    { vaccine_name: "", vaccinated_on: nil }
  end

  describe "GET /index" do
    it "200を返す" do
      create(:vaccine_record)
      get vaccine_records_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /new" do
    it "200を返す" do
      get new_vaccine_record_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /edit" do
    it "200を返す" do
      record = create(:vaccine_record)
      get edit_vaccine_record_path(record)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /create" do
    context "有効なパラメータのとき" do
      it "接種記録を1件作成する" do
        expect {
          post vaccine_records_path, params: { vaccine_record: valid_attributes }
        }.to change(VaccineRecord, :count).by(1)
      end

      it "一覧ページにリダイレクトする" do
        post vaccine_records_path, params: { vaccine_record: valid_attributes }
        expect(response).to redirect_to(vaccine_records_path)
      end
    end

    context "無効なパラメータのとき" do
      it "422を返す" do
        post vaccine_records_path, params: { vaccine_record: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "レコードを作成しない" do
        expect {
          post vaccine_records_path, params: { vaccine_record: invalid_attributes }
        }.not_to change(VaccineRecord, :count)
      end
    end
  end

  describe "PATCH /update" do
    context "有効なパラメータのとき" do
      it "接種記録を更新して一覧にリダイレクトする" do
        record = create(:vaccine_record)
        patch vaccine_record_path(record), params: { vaccine_record: { vaccine_name: "Updated vaccine" } }
        expect(response).to redirect_to(vaccine_records_path)
        expect(record.reload.vaccine_name).to eq("Updated vaccine")
      end
    end

    context "無効なパラメータのとき" do
      it "422を返す" do
        record = create(:vaccine_record)
        patch vaccine_record_path(record), params: { vaccine_record: { vaccine_name: "" } }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE /destroy" do
    it "接種記録を削除する" do
      record = create(:vaccine_record)
      expect {
        delete vaccine_record_path(record)
      }.to change(VaccineRecord, :count).by(-1)
    end
  end
end
