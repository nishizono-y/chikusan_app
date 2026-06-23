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
end
