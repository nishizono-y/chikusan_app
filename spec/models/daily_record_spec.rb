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

    describe '#feed_stock_low?' do
      it 'feed_stockがしきい値以下のとき真を返す' do
        subject.feed_stock = 300
        expect(subject.feed_stock_low?).to be true
      end

      it 'feed_stockがしきい値を超えているとき偽を返す' do
        subject.feed_stock = 301
        expect(subject.feed_stock_low?).to be false
      end

      it 'feed_stockがnilのとき偽を返す' do
        subject.feed_stock = nil
        expect(subject.feed_stock_low?).to be_falsey
      end
    end

    describe '#estimated_remaining_days' do
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
        subject.feed_stock = 301
        subject.feed_usage = 100
        expect(subject.estimated_remaining_days).to be_nil
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
end
