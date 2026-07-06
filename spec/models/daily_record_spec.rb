require 'rails_helper'

RSpec.describe DailyRecord, type: :model do
  describe 'バリデーション' do
    subject { build(:daily_record) }

    it '有効なデータで保存できる' do
      expect(subject).to be_valid
    end

    describe 'date' do
      it '必須である' do
        subject.date = nil
        expect(subject).not_to be_valid
        expect(subject.errors[:date]).to be_present
      end

      it '同じ日付は登録できない' do
        create(:daily_record, date: Date.current)
        subject.date = Date.current
        expect(subject).not_to be_valid
        expect(subject.errors[:date]).to be_present
      end
    end

    describe 'livestock_type' do
      it '未設定でも保存できる' do
        subject.livestock_type = nil
        expect(subject).to be_valid
      end

      it '畜種を設定して保存できる' do
        subject.livestock_type = create(:livestock_type)
        expect(subject).to be_valid
      end
    end

    describe 'head_count' do
      it '必須である' do
        subject.head_count = nil
        expect(subject).not_to be_valid
      end

      it '0以上の整数であること' do
        subject.head_count = -1
        expect(subject).not_to be_valid
      end

      it '0は有効' do
        subject.head_count = 0
        expect(subject).to be_valid
      end
    end

    describe 'death_count' do
      it '必須である' do
        subject.death_count = nil
        expect(subject).not_to be_valid
      end

      it '0以上の整数であること' do
        subject.death_count = -1
        expect(subject).not_to be_valid
      end

      it '0は有効' do
        subject.death_count = 0
        expect(subject).to be_valid
      end
    end

    describe 'feed_usage' do
      it '必須である' do
        subject.feed_usage = nil
        expect(subject).not_to be_valid
      end

      it '0以上の整数であること' do
        subject.feed_usage = -1
        expect(subject).not_to be_valid
      end
    end

    describe 'feed_stock' do
      it '必須である' do
        subject.feed_stock = nil
        expect(subject).not_to be_valid
      end

      it '0以上の整数であること' do
        subject.feed_stock = -1
        expect(subject).not_to be_valid
      end
    end

    describe 'vaccine' do
      it '空白は有効' do
        subject.vaccine = ''
        expect(subject).to be_valid
      end

      it '定義された選択肢は有効' do
        DailyRecord::VACCINE_OPTIONS.each do |option|
          subject.vaccine = option
          expect(subject).to be_valid
        end
      end

      it '定義外の値は無効' do
        subject.vaccine = '無効な値'
        expect(subject).not_to be_valid
      end
    end
  end

  describe '#vaccine_given?' do
    subject { build(:daily_record) }

    it 'vaccineが「なし」のとき偽を返す' do
      subject.vaccine = 'なし'
      expect(subject.vaccine_given?).to be false
    end

    it 'vaccineが空のとき偽を返す' do
      subject.vaccine = ''
      expect(subject.vaccine_given?).to be false
    end

    it 'vaccineが「なし」以外のとき真を返す' do
      subject.vaccine = '口蹄疫'
      expect(subject.vaccine_given?).to be true
    end
  end

  describe '#feed_stock_low?' do
    subject { build(:daily_record) }

    it 'feed_stockがしきい値以下のとき真を返す' do
      subject.feed_stock = Setting.feed_stock_threshold
      expect(subject.feed_stock_low?).to be true
    end

    it 'feed_stockがしきい値を超えているとき偽を返す' do
      subject.feed_stock = Setting.feed_stock_threshold + 1
      expect(subject.feed_stock_low?).to be false
    end

    it 'feed_stockがnilのとき偽を返す' do
      subject.feed_stock = nil
      expect(subject.feed_stock_low?).to be_falsey
    end

    it '設定画面で変更したしきい値が反映される' do
      Setting.create!(name: Setting::FEED_STOCK_KEY, value: 500)
      subject.feed_stock = 400
      expect(subject.feed_stock_low?).to be true
      subject.feed_stock = 501
      expect(subject.feed_stock_low?).to be false
    end
  end

  describe '.mortality_alert' do
    let(:base_date) { Date.new(2026, 6, 25) }

    def build_past(date:, death_count:, head_count:)
      create(:daily_record, date: date, death_count: death_count, head_count: head_count)
    end

    context '当日の記録がnil' do
      it 'nilを返す' do
        expect(DailyRecord.mortality_alert(nil)).to be_nil
      end
    end

    context '当日の死亡頭数が0' do
      it 'nilを返す' do
        today = create(:daily_record, date: base_date, death_count: 0, head_count: 100)
        expect(DailyRecord.mortality_alert(today)).to be_nil
      end
    end

    context '当日の飼養頭数が0' do
      it 'nilを返す' do
        today = create(:daily_record, date: base_date, death_count: 3, head_count: 0)
        expect(DailyRecord.mortality_alert(today)).to be_nil
      end
    end

    context '過去30日間に死亡ゼロ（平均死亡率が0）' do
      it 'nilを返す' do
        (1..5).each { |i| build_past(date: base_date - i, death_count: 0, head_count: 100) }
        today = create(:daily_record, date: base_date, death_count: 3, head_count: 100)
        expect(DailyRecord.mortality_alert(today)).to be_nil
      end
    end

    context '当日死亡率が平均の2倍以上3倍未満' do
      it 'level: :warning を返す' do
        # 過去30日: 死亡率 1% (1/100)
        (1..5).each { |i| build_past(date: base_date - i, death_count: 1, head_count: 100) }
        # 当日: 死亡率 2.5% (25/1000)
        today = create(:daily_record, date: base_date, death_count: 25, head_count: 1000)
        result = DailyRecord.mortality_alert(today)
        expect(result[:level]).to eq(:warning)
        expect(result[:ratio]).to be >= 2.0
        expect(result[:ratio]).to be < 3.0
      end
    end

    context '当日死亡率が平均の3倍以上' do
      it 'level: :danger を返す' do
        # 過去30日: 死亡率 1% (1/100)
        (1..5).each { |i| build_past(date: base_date - i, death_count: 1, head_count: 100) }
        # 当日: 死亡率 4% (4/100)
        today = create(:daily_record, date: base_date, death_count: 40, head_count: 1000)
        result = DailyRecord.mortality_alert(today)
        expect(result[:level]).to eq(:danger)
        expect(result[:ratio]).to be >= 3.0
      end
    end

    context '当日死亡率が平均の2倍未満' do
      it 'nilを返す' do
        (1..5).each { |i| build_past(date: base_date - i, death_count: 2, head_count: 100) }
        today = create(:daily_record, date: base_date, death_count: 3, head_count: 100)
        expect(DailyRecord.mortality_alert(today)).to be_nil
      end
    end

    context '30日より前の記録は除外される' do
      it '31日前のデータは計算に含まれない' do
        # 31日前に高死亡率の記録があっても影響しない
        build_past(date: base_date - 31, death_count: 10, head_count: 100)
        today = create(:daily_record, date: base_date, death_count: 5, head_count: 100)
        # 過去30日にデータがないためnilを返す
        expect(DailyRecord.mortality_alert(today)).to be_nil
      end
    end
  end

  describe '#estimated_remaining_days' do
    subject { build(:daily_record) }

    it '在庫と使用量から残日数を切り上げで返す' do
      subject.feed_stock = 200
      subject.feed_usage = 50
      expect(subject.estimated_remaining_days).to eq(4)
    end

    it '在庫が使用量未満のとき1を返す' do
      subject.feed_stock = 10
      subject.feed_usage = 50
      expect(subject.estimated_remaining_days).to eq(1)
    end

    it '在庫が0のときnilを返す' do
      subject.feed_stock = 0
      subject.feed_usage = 100
      expect(subject.estimated_remaining_days).to be_nil
    end

    it 'feed_usageが0のときnilを返す' do
      subject.feed_stock = 200
      subject.feed_usage = 0
      expect(subject.estimated_remaining_days).to be_nil
    end

    it 'feed_stockがしきい値を超えているときnilを返す' do
      subject.feed_stock = Setting.feed_stock_threshold + 1
      subject.feed_usage = 100
      expect(subject.estimated_remaining_days).to be_nil
    end
  end
end
