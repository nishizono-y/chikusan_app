require 'rails_helper'

RSpec.describe FeedOrder, type: :model do
  describe 'バリデーション' do
    subject { build(:feed_order) }

    it '有効なデータで保存できる' do
      expect(subject).to be_valid
    end

    describe 'ordered_on' do
      it '必須である' do
        subject.ordered_on = nil
        expect(subject).not_to be_valid
        expect(subject.errors[:ordered_on]).to be_present
      end
    end

    describe 'quantity' do
      it '必須である' do
        subject.quantity = nil
        expect(subject).not_to be_valid
      end

      it '0以下は無効' do
        subject.quantity = 0
        expect(subject).not_to be_valid
      end

      it '整数でなければ無効' do
        subject.quantity = 1.5
        expect(subject).not_to be_valid
      end
    end

    describe 'supplier' do
      it '必須である' do
        subject.supplier = nil
        expect(subject).not_to be_valid
        expect(subject.errors[:supplier]).to be_present
      end

      it '空文字は無効' do
        subject.supplier = ''
        expect(subject).not_to be_valid
      end
    end

    describe 'memo' do
      it '未設定でも保存できる' do
        subject.memo = nil
        expect(subject).to be_valid
      end
    end
  end
end
