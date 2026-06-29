require "rails_helper"

RSpec.describe "/setting", type: :request do
  describe "GET /setting/edit" do
    it "200を返す" do
      get edit_setting_path
      expect(response).to have_http_status(:ok)
    end

    it "しきい値入力フォームを表示する" do
      get edit_setting_path
      expect(response.body).to include("アラートしきい値")
    end
  end

  describe "PATCH /setting" do
    context "有効な値を送信したとき" do
      it "設定を保存して設定ページにリダイレクトする" do
        patch setting_path, params: { setting: { value: 500 } }
        expect(response).to redirect_to(edit_setting_path)
        follow_redirect!
        expect(response.body).to include("設定を保存しました")
      end

      it "DBにしきい値が保存される" do
        patch setting_path, params: { setting: { value: 500 } }
        expect(Setting.feed_stock_threshold).to eq(500)
      end

      it "value 以外のパラメータは無視される（strong parameters）" do
        patch setting_path, params: { setting: { value: 400, name: "tampered" } }
        expect(response).to redirect_to(edit_setting_path)
        expect(Setting.find_by(name: "tampered")).to be_nil
      end
    end

    context "無効な値を送信したとき" do
      it "422を返してフォームを再表示する" do
        patch setting_path, params: { setting: { value: 0 } }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("field-error")
      end

      it "DBの値が変更されないこと" do
        Setting.create!(name: Setting::FEED_STOCK_KEY, value: 300)
        patch setting_path, params: { setting: { value: -1 } }
        expect(Setting.feed_stock_threshold).to eq(300)
      end
    end
  end
end
