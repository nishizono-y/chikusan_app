require "rails_helper"

RSpec.describe "/farm_settings", type: :request do
  describe "GET /edit" do
    it "200を返す" do
      get edit_farm_settings_path
      expect(response).to have_http_status(:ok)
    end

    it "デフォルトの緯度経度を表示する" do
      get edit_farm_settings_path
      expect(response.body).to include(Setting::DEFAULTS[Setting::FARM_LAT_KEY].to_s)
      expect(response.body).to include(Setting::DEFAULTS[Setting::FARM_LON_KEY].to_s)
    end
  end

  describe "PATCH /update" do
    context "有効な値を送信したとき" do
      it "設定を保存して編集ページにリダイレクトする" do
        patch farm_settings_path, params: { farm_settings: { lat: "35.6812", lon: "139.7671" } }
        expect(response).to redirect_to(edit_farm_settings_path)
        follow_redirect!
        expect(response.body).to include("農場設定を保存しました")
      end

      it "DBに緯度経度が保存される" do
        patch farm_settings_path, params: { farm_settings: { lat: "35.6812", lon: "139.7671" } }
        expect(Setting.farm_lat.to_f).to eq(35.6812)
        expect(Setting.farm_lon.to_f).to eq(139.7671)
      end

      it "lat/lon 以外のパラメータは無視される（strong parameters）" do
        patch farm_settings_path, params: { farm_settings: { lat: "35.6812", lon: "139.7671", name: "tampered" } }
        expect(Setting.find_by(name: "tampered")).to be_nil
      end
    end

    context "無効な値を送信したとき" do
      it "422を返して編集画面を再表示する" do
        patch farm_settings_path, params: { farm_settings: { lat: "999", lon: "139.7671" } }
        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include("field-error")
      end

      it "片方が無効な場合はもう片方も保存されない" do
        patch farm_settings_path, params: { farm_settings: { lat: "999", lon: "139.7671" } }
        expect(Setting.farm_lat.to_f).to eq(Setting::DEFAULTS[Setting::FARM_LAT_KEY])
        expect(Setting.farm_lon.to_f).to eq(Setting::DEFAULTS[Setting::FARM_LON_KEY])
      end

      it "緯度・経度の両方が無効な場合、両方のエラーメッセージを表示する" do
        patch farm_settings_path, params: { farm_settings: { lat: "999", lon: "-200" } }
        expect(response.body.scan("<span class=\"field-error\">").length).to eq(2)
      end
    end
  end
end
