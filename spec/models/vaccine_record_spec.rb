require "rails_helper"

RSpec.describe VaccineRecord, type: :model do
  describe "バリデーション" do
    subject { build(:vaccine_record) }

    it "有効なデータで保存できる" do
      expect(subject).to be_valid
    end

    describe "vaccine_name" do
      it "必須である" do
        subject.vaccine_name = nil
        expect(subject).not_to be_valid
        expect(subject.errors[:vaccine_name]).to be_present
      end
    end

    describe "vaccinated_on" do
      it "必須である" do
        subject.vaccinated_on = nil
        expect(subject).not_to be_valid
        expect(subject.errors[:vaccinated_on]).to be_present
      end
    end

    describe "head_count" do
      it "nil の場合は有効" do
        subject.head_count = nil
        expect(subject).to be_valid
      end

      it "1以上の整数であること" do
        subject.head_count = 0
        expect(subject).not_to be_valid
      end

      it "負の値は無効" do
        subject.head_count = -1
        expect(subject).not_to be_valid
      end
    end
  end

  describe "#overdue?" do
    it "next_due_on が過去の場合は true" do
      record = build(:vaccine_record, next_due_on: Date.yesterday)
      expect(record.overdue?).to be true
    end

    it "next_due_on が今日の場合は true" do
      record = build(:vaccine_record, next_due_on: Date.current)
      expect(record.overdue?).to be true
    end

    it "next_due_on が nil の場合は false" do
      record = build(:vaccine_record, next_due_on: nil)
      expect(record.overdue?).to be false
    end
  end

  describe "#due_soon?" do
    it "next_due_on が明日から7日以内なら true" do
      record = build(:vaccine_record, next_due_on: Date.current + 3)
      expect(record.due_soon?).to be true
    end

    it "next_due_on が今日の場合は false（overdue に分類される）" do
      record = build(:vaccine_record, next_due_on: Date.current)
      expect(record.due_soon?).to be false
    end

    it "next_due_on が8日後なら false" do
      record = build(:vaccine_record, next_due_on: Date.current + 8)
      expect(record.due_soon?).to be false
    end

    it "next_due_on が過去なら false" do
      record = build(:vaccine_record, next_due_on: Date.yesterday)
      expect(record.due_soon?).to be false
    end
  end
end
