require "rails_helper"

RSpec.describe ApplicationHelper, type: :helper do
  describe "#ja_date" do
    it "nilのとき nil を返す" do
      expect(helper.ja_date(nil)).to be_nil
    end

    it "年なし・月日・曜日付きでフォーマットする" do
      date = Date.new(2026, 6, 24) # 水曜日
      expect(helper.ja_date(date)).to eq("6月24日（水）")
    end

    it "曜日が正しく対応している" do
      # 2026-06-21 は日曜
      expect(helper.ja_date(Date.new(2026, 6, 21))).to include("日")
      # 2026-06-22 は月曜
      expect(helper.ja_date(Date.new(2026, 6, 22))).to include("月")
    end

    it "月・日の先頭ゼロを付けない" do
      date = Date.new(2026, 1, 5)
      expect(helper.ja_date(date)).to eq("1月5日（月）")
    end
  end

  describe "#ja_date_full" do
    it "nilのとき nil を返す" do
      expect(helper.ja_date_full(nil)).to be_nil
    end

    it "年あり・曜日なしでフォーマットする" do
      date = Date.new(2026, 6, 24)
      expect(helper.ja_date_full(date)).to eq("2026年6月24日")
    end

    it "月・日の先頭ゼロを付けない" do
      date = Date.new(2026, 1, 5)
      expect(helper.ja_date_full(date)).to eq("2026年1月5日")
    end
  end
end
