require "rails_helper"

RSpec.describe Setting, type: :model do
  describe "validations" do
    it "有効な設定で保存できる" do
      expect(Setting.new(name: Setting::FEED_STOCK_KEY, value: 200)).to be_valid
    end

    it "valueが0以下は無効" do
      expect(Setting.new(name: Setting::FEED_STOCK_KEY, value: 0)).not_to be_valid
      expect(Setting.new(name: Setting::FEED_STOCK_KEY, value: -1)).not_to be_valid
    end

    it "valueが空は無効" do
      expect(Setting.new(name: Setting::FEED_STOCK_KEY, value: nil)).not_to be_valid
    end

    it "nameが重複するレコードは無効" do
      Setting.create!(name: Setting::FEED_STOCK_KEY, value: 300)
      expect(Setting.new(name: Setting::FEED_STOCK_KEY, value: 500)).not_to be_valid
    end
  end

  describe ".[]" do
    context "レコードが存在しない場合" do
      it "デフォルト値を返す" do
        expect(Setting[Setting::FEED_STOCK_KEY]).to eq(Setting::DEFAULTS[Setting::FEED_STOCK_KEY])
      end
    end

    context "レコードが存在する場合" do
      it "保存された値を返す" do
        Setting.create!(name: Setting::FEED_STOCK_KEY, value: 500)
        expect(Setting[Setting::FEED_STOCK_KEY]).to eq(500)
      end
    end
  end

  describe ".feed_stock_threshold" do
    context "レコードが存在しない場合" do
      it "デフォルト値を返す" do
        expect(Setting.feed_stock_threshold).to eq(Setting::DEFAULTS[Setting::FEED_STOCK_KEY])
      end
    end

    context "レコードが存在する場合" do
      it "保存されたしきい値を返す" do
        Setting.create!(name: Setting::FEED_STOCK_KEY, value: 500)
        expect(Setting.feed_stock_threshold).to eq(500)
      end
    end
  end

  describe ".fetch" do
    it "レコードが存在しない場合は未保存レコードをデフォルト値付きで返す" do
      s = Setting.fetch(Setting::FEED_STOCK_KEY)
      expect(s).not_to be_persisted
      expect(s.value).to eq(Setting::DEFAULTS[Setting::FEED_STOCK_KEY])
    end

    it "レコードが存在する場合は既存レコードを返す" do
      Setting.create!(name: Setting::FEED_STOCK_KEY, value: 500)
      s = Setting.fetch(Setting::FEED_STOCK_KEY)
      expect(s).to be_persisted
      expect(s.value).to eq(500)
    end
  end
end
