require 'rails_helper'

RSpec.describe Shipment, type: :model do
  describe 'バリデーション' do
    subject { build(:shipment) }

    it '有効なデータで保存できる' do
      expect(subject).to be_valid
    end

    describe 'shipped_at' do
      it '必須である' do
        subject.shipped_at = nil
        expect(subject).not_to be_valid
        expect(subject.errors[:shipped_at]).to be_present
      end
    end

    describe 'count' do
      it '必須である' do
        subject.count = nil
        expect(subject).not_to be_valid
      end

      it '1以上の整数であること' do
        subject.count = 0
        expect(subject).not_to be_valid
      end

      it '負の値は無効' do
        subject.count = -1
        expect(subject).not_to be_valid
      end
    end

    describe 'avg_weight' do
      it '必須である' do
        subject.avg_weight = nil
        expect(subject).not_to be_valid
      end

      it '0より大きい値であること' do
        subject.avg_weight = 0
        expect(subject).not_to be_valid
      end

      it '小数点を含む値は有効' do
        subject.avg_weight = 450.5
        expect(subject).to be_valid
      end
    end

    describe 'destination' do
      it '必須である' do
        subject.destination = nil
        expect(subject).not_to be_valid
        expect(subject.errors[:destination]).to be_present
      end

      it '空文字は無効' do
        subject.destination = ''
        expect(subject).not_to be_valid
      end
    end
  end
end
