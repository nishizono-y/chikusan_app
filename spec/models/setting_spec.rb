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

    it "nameが重複するレコードはDBのユニーク制約で拒否される" do
      Setting.create!(name: Setting::FEED_STOCK_KEY, value: 300)
      expect {
        Setting.create!(name: Setting::FEED_STOCK_KEY, value: 500)
      }.to raise_error(ActiveRecord::RecordNotUnique)
    end

    it "farm_latは小数の緯度で保存できる" do
      expect(Setting.new(name: Setting::FARM_LAT_KEY, value: 31.8159)).to be_valid
    end

    it "farm_latが範囲外（-90〜90）は無効" do
      expect(Setting.new(name: Setting::FARM_LAT_KEY, value: 91)).not_to be_valid
      expect(Setting.new(name: Setting::FARM_LAT_KEY, value: -91)).not_to be_valid
    end

    it "farm_lonは小数の経度で保存できる" do
      expect(Setting.new(name: Setting::FARM_LON_KEY, value: 130.3006)).to be_valid
    end

    it "farm_lonが範囲外（-180〜180）は無効" do
      expect(Setting.new(name: Setting::FARM_LON_KEY, value: 181)).not_to be_valid
      expect(Setting.new(name: Setting::FARM_LON_KEY, value: -181)).not_to be_valid
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

  describe ".farm_lat / .farm_lon" do
    context "レコードが存在しない場合" do
      it "デフォルトの緯度経度を返す" do
        expect(Setting.farm_lat).to eq(Setting::DEFAULTS[Setting::FARM_LAT_KEY])
        expect(Setting.farm_lon).to eq(Setting::DEFAULTS[Setting::FARM_LON_KEY])
      end
    end

    context "レコードが存在する場合" do
      it "保存された緯度経度を返す" do
        Setting.create!(name: Setting::FARM_LAT_KEY, value: 35.6812)
        Setting.create!(name: Setting::FARM_LON_KEY, value: 139.7671)
        expect(Setting.farm_lat.to_f).to eq(35.6812)
        expect(Setting.farm_lon.to_f).to eq(139.7671)
      end
    end
  end

  describe ".fetch" do
    it "レコードが存在しない場合はデフォルト値で作成して返す" do
      s = Setting.fetch(Setting::FEED_STOCK_KEY)
      expect(s).to be_persisted
      expect(s.value).to eq(Setting::DEFAULTS[Setting::FEED_STOCK_KEY])
    end

    it "レコードが存在する場合は既存レコードを返す" do
      # create_or_find_by! は既存レコードの有無に関わらず先にINSERTを試みるため、
      # このケースは実際にDBのユニーク制約違反（RecordNotUnique）を発生させ、
      # 内部でそれを捕捉して既存レコードを再取得する経路を通る（レース対策の実動作確認を兼ねる）。
      existing = Setting.create!(name: Setting::FEED_STOCK_KEY, value: 500)
      s = Setting.fetch(Setting::FEED_STOCK_KEY)
      expect(s).to eq(existing)
      expect(s.value).to eq(500)
      expect(Setting.where(name: Setting::FEED_STOCK_KEY).count).to eq(1)
    end

    it "SQLiteのロック競合（StatementTimeout）が一時的なら1回の再試行で成功する" do
      call_count = 0
      allow(Setting).to receive(:create_or_find_by!).and_wrap_original do |original, *args, &block|
        call_count += 1
        raise ActiveRecord::StatementTimeout if call_count == 1
        original.call(*args, &block)
      end

      s = Setting.fetch(Setting::FEED_STOCK_KEY)

      expect(s.value).to eq(Setting::DEFAULTS[Setting::FEED_STOCK_KEY])
      expect(call_count).to eq(2)
    end

    it "StatementTimeoutが2回連続で発生した場合は再試行せず例外を伝播する" do
      allow(Setting).to receive(:create_or_find_by!).and_raise(ActiveRecord::StatementTimeout)

      expect { Setting.fetch(Setting::FEED_STOCK_KEY) }.to raise_error(ActiveRecord::StatementTimeout)
    end
  end
end
