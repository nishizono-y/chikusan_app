require "rails_helper"

RSpec.describe Setting, type: :model do
  describe "validations" do
    it "有効なしきい値で保存できる" do
      setting = Setting.new(feed_stock_threshold: 200)
      expect(setting).to be_valid
    end

    it "しきい値が0以下は無効" do
      expect(Setting.new(feed_stock_threshold: 0)).not_to be_valid
      expect(Setting.new(feed_stock_threshold: -1)).not_to be_valid
    end

    it "しきい値が空は無効" do
      expect(Setting.new(feed_stock_threshold: nil)).not_to be_valid
    end
  end

  describe ".feed_stock_threshold" do
    context "Settingレコードが存在しない場合" do
      it "デフォルト値を返す" do
        expect(Setting.feed_stock_threshold).to eq(Setting::DEFAULT_FEED_STOCK_THRESHOLD)
      end
    end

    context "Settingレコードが存在する場合" do
      it "保存されたしきい値を返す" do
        Setting.create!(feed_stock_threshold: 500)
        expect(Setting.feed_stock_threshold).to eq(500)
      end
    end
  end
end
