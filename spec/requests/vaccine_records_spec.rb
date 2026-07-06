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

    it "ワクチン名ごとにグループ化し、各グループ内は接種日の降順で表示する" do
      create(:vaccine_record, vaccine_name: "口蹄疫", vaccinated_on: Date.current - 400)
      create(:vaccine_record, vaccine_name: "口蹄疫", vaccinated_on: Date.current - 30)
      create(:vaccine_record, vaccine_name: "牛白血病", vaccinated_on: Date.current - 10)

      get vaccine_records_path
      doc = Nokogiri::HTML5(response.body)

      # グループは最新の接種日が新しい順（牛白血病: -10日 → 口蹄疫: -30日）に並ぶ
      group_names = doc.css("details.card summary").map { |summary| summary.text.strip.lines.first.strip }
      expect(group_names.first(2)).to eq(%w[牛白血病 口蹄疫])

      # 口蹄疫グループ内は接種日の降順（-30日 → -400日）に並ぶ
      kuchitei_group = doc.css("details.card").find { |group| group.at_css("summary").text.include?("口蹄疫") }
      vaccinated_on_cells = kuchitei_group.css("tbody tr td:first-child").map(&:text)
      expect(vaccinated_on_cells).to eq([ Date.current - 30, Date.current - 400 ].map { |date| date.strftime("%Y年%-m月%-d日") })
    end
  end

  describe "GET /show" do
    it "200を返す" do
      record = create(:vaccine_record)
      get vaccine_record_path(record)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /new" do
    it "200を返す" do
      get new_vaccine_record_path
      expect(response).to have_http_status(:ok)
    end

    it "日次記録から接種日とワクチン名を引き継いで初期値に反映する" do
      get new_vaccine_record_path(vaccinated_on: "2026-06-18", vaccine_name: "口蹄疫")
      expect(response.body).to include(%(value="2026-06-18"))
      expect(response.body).to include(%(value="口蹄疫"))
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

      it "詳細ページにリダイレクトする" do
        post vaccine_records_path, params: { vaccine_record: valid_attributes }
        expect(response).to redirect_to(vaccine_record_path(VaccineRecord.last))
      end
    end

    context "無効なパラメータのとき" do
      it "422を返す" do
        post vaccine_records_path, params: { vaccine_record: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_content)
      end

      it "レコードを作成しない" do
        expect {
          post vaccine_records_path, params: { vaccine_record: invalid_attributes }
        }.not_to change(VaccineRecord, :count)
      end
    end

    context "JSON形式のとき" do
      it "有効なパラメータなら201とレコードのJSONを返す" do
        post vaccine_records_path, params: { vaccine_record: valid_attributes }, as: :json
        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)["vaccine_name"]).to eq("FMD vaccine")
      end

      it "無効なパラメータなら422とエラーのJSONを返す" do
        post vaccine_records_path, params: { vaccine_record: invalid_attributes }, as: :json
        expect(response).to have_http_status(:unprocessable_content)
        expect(JSON.parse(response.body)).to have_key("vaccine_name")
      end
    end
  end

  describe "PATCH /update" do
    context "有効なパラメータのとき" do
      it "接種記録を更新して詳細ページにリダイレクトする" do
        record = create(:vaccine_record)
        patch vaccine_record_path(record), params: { vaccine_record: { vaccine_name: "Updated vaccine" } }
        expect(response).to redirect_to(vaccine_record_path(record))
        expect(record.reload.vaccine_name).to eq("Updated vaccine")
      end
    end

    context "無効なパラメータのとき" do
      it "422を返す" do
        record = create(:vaccine_record)
        patch vaccine_record_path(record), params: { vaccine_record: { vaccine_name: "" } }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    context "JSON形式のとき" do
      it "有効なパラメータなら200とレコードのJSONを返す" do
        record = create(:vaccine_record)
        patch vaccine_record_path(record), params: { vaccine_record: { vaccine_name: "Updated" } }, as: :json
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)["vaccine_name"]).to eq("Updated")
      end

      it "無効なパラメータなら422とエラーのJSONを返す" do
        record = create(:vaccine_record)
        patch vaccine_record_path(record), params: { vaccine_record: { vaccine_name: "" } }, as: :json
        expect(response).to have_http_status(:unprocessable_content)
        expect(JSON.parse(response.body)).to have_key("vaccine_name")
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

    it "HTML フォーマットで一覧に 303 リダイレクトする" do
      record = create(:vaccine_record)
      delete vaccine_record_path(record)
      expect(response).to have_http_status(:see_other)
      expect(response).to redirect_to(vaccine_records_path)
    end

    it "Turbo Stream フォーマットで 200 を返す" do
      record = create(:vaccine_record)
      delete vaccine_record_path(record), headers: { "Accept" => "text/vnd.turbo-stream.html" }
      expect(response).to have_http_status(:ok)
    end

    it "JSON フォーマットで 204 を返す" do
      record = create(:vaccine_record)
      delete vaccine_record_path(record), as: :json
      expect(response).to have_http_status(:no_content)
    end
  end
end
