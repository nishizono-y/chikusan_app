require 'rails_helper'

RSpec.describe LivestockType, type: :model do
  describe 'バリデーション' do
    subject { build(:livestock_type) }

    it '有効なデータで保存できる' do
      expect(subject).to be_valid
    end

    describe 'name' do
      it '必須である' do
        subject.name = nil
        expect(subject).not_to be_valid
        expect(subject.errors[:name]).to be_present
      end

      it '重複した名前は無効' do
        create(:livestock_type, name: "肉用牛")
        subject.name = "肉用牛"
        expect(subject).not_to be_valid
      end
    end

    describe 'unit' do
      it '必須である' do
        subject.unit = nil
        expect(subject).not_to be_valid
        expect(subject.errors[:unit]).to be_present
      end
    end
  end

  describe '削除' do
    it '関連する日次記録がある場合は削除できない' do
      livestock_type = create(:livestock_type)
      create(:daily_record, livestock_type: livestock_type)

      expect(livestock_type.destroy).to be_falsey
      expect(livestock_type.errors[:base]).to be_present
    end

    it '関連する日次記録がない場合は削除できる' do
      livestock_type = create(:livestock_type)
      expect(livestock_type.destroy).to be_truthy
    end
  end
end
