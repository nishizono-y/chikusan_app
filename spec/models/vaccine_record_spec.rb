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

  describe "日次記録との連携" do
    it "同じ日付の日次記録がワクチン「なし」のとき、一致するワクチン名で自動更新する" do
      daily_record = create(:daily_record, date: Date.new(2026, 6, 18), vaccine: "なし")
      create(:vaccine_record, vaccine_name: "口蹄疫", vaccinated_on: daily_record.date)
      expect(daily_record.reload.vaccine).to eq("口蹄疫")
    end

    it "一致する選択肢がないワクチン名の場合は「その他」にする" do
      daily_record = create(:daily_record, date: Date.new(2026, 6, 18), vaccine: "なし")
      create(:vaccine_record, vaccine_name: "FMD vaccine", vaccinated_on: daily_record.date)
      expect(daily_record.reload.vaccine).to eq("その他")
    end

    it "同じ日付の日次記録が既にワクチン記録済みのときは上書きしない" do
      daily_record = create(:daily_record, date: Date.new(2026, 6, 18), vaccine: "ブルセラ")
      create(:vaccine_record, vaccine_name: "口蹄疫", vaccinated_on: daily_record.date)
      expect(daily_record.reload.vaccine).to eq("ブルセラ")
    end

    it "同じ日付の日次記録が存在しないときは何もしない" do
      expect {
        create(:vaccine_record, vaccinated_on: Date.new(2026, 6, 30))
      }.not_to raise_error
    end

    it "このレコードが自動反映した値であれば、ワクチン名を訂正すると日次記録も追従する" do
      daily_record = create(:daily_record, date: Date.new(2026, 6, 18), vaccine: "なし")
      vaccine_record = create(:vaccine_record, vaccine_name: "ブルセラ", vaccinated_on: daily_record.date)
      expect(daily_record.reload.vaccine).to eq("ブルセラ")

      vaccine_record.update!(vaccine_name: "口蹄疫")
      expect(daily_record.reload.vaccine).to eq("口蹄疫")
    end

    it "日次記録が手動で別の値に変更されていれば、ワクチン名を訂正しても上書きしない" do
      daily_record = create(:daily_record, date: Date.new(2026, 6, 18), vaccine: "なし")
      vaccine_record = create(:vaccine_record, vaccine_name: "ブルセラ", vaccinated_on: daily_record.date)
      daily_record.update!(vaccine: "その他")

      vaccine_record.update!(vaccine_name: "口蹄疫")
      expect(daily_record.reload.vaccine).to eq("その他")
    end

    it "接種日を変更すると、このレコードが反映していた旧日付の日次記録は「なし」に戻る" do
      old_daily_record = create(:daily_record, date: Date.new(2026, 6, 18), vaccine: "なし")
      new_daily_record = create(:daily_record, date: Date.new(2026, 6, 19), vaccine: "なし")
      vaccine_record = create(:vaccine_record, vaccine_name: "口蹄疫", vaccinated_on: old_daily_record.date)
      expect(old_daily_record.reload.vaccine).to eq("口蹄疫")

      vaccine_record.update!(vaccinated_on: new_daily_record.date)
      expect(old_daily_record.reload.vaccine).to eq("なし")
      expect(new_daily_record.reload.vaccine).to eq("口蹄疫")
    end

    it "接種日を変更しても、旧日付の日次記録が手動で別の値に変更されていればリセットしない" do
      old_daily_record = create(:daily_record, date: Date.new(2026, 6, 18), vaccine: "なし")
      new_daily_record = create(:daily_record, date: Date.new(2026, 6, 19), vaccine: "なし")
      vaccine_record = create(:vaccine_record, vaccine_name: "口蹄疫", vaccinated_on: old_daily_record.date)
      old_daily_record.update!(vaccine: "ブルセラ")

      vaccine_record.update!(vaccinated_on: new_daily_record.date)
      expect(old_daily_record.reload.vaccine).to eq("ブルセラ")
    end

    it "vaccinated_onもvaccine_nameも変更しない保存では日次記録を再検索しない" do
      daily_record = create(:daily_record, date: Date.new(2026, 6, 18), vaccine: "なし")
      vaccine_record = create(:vaccine_record, vaccine_name: "口蹄疫", vaccinated_on: daily_record.date)
      daily_record.update!(vaccine: "その他")

      vaccine_record.update!(notes: "頭数を再確認")
      expect(daily_record.reload.vaccine).to eq("その他")
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

  describe "再接種時の期限判定" do
    it "同じワクチンを再接種すると、古い記録は overdue? が false になる" do
      old_record = create(:vaccine_record, vaccine_name: "口蹄疫", vaccinated_on: Date.current - 90, next_due_on: Date.yesterday)
      create(:vaccine_record, vaccine_name: "口蹄疫", vaccinated_on: Date.current, next_due_on: Date.current + 60)

      expect(old_record.reload.overdue?).to be false
    end

    it "同じワクチンを再接種すると、古い記録は due_soon? が false になる" do
      old_record = create(:vaccine_record, vaccine_name: "口蹄疫", vaccinated_on: Date.current - 90, next_due_on: Date.current + 3)
      create(:vaccine_record, vaccine_name: "口蹄疫", vaccinated_on: Date.current, next_due_on: Date.current + 60)

      expect(old_record.reload.due_soon?).to be false
    end

    it "最新の接種記録は次回接種予定日に応じて overdue?/due_soon? が有効なままである" do
      create(:vaccine_record, vaccine_name: "口蹄疫", vaccinated_on: Date.current - 90, next_due_on: Date.yesterday)
      latest_record = create(:vaccine_record, vaccine_name: "口蹄疫", vaccinated_on: Date.current, next_due_on: Date.yesterday)

      expect(latest_record.overdue?).to be true
    end

    it "異なるワクチン名の記録には影響しない" do
      other_vaccine_latest = create(:vaccine_record, vaccine_name: "ブルセラ", vaccinated_on: Date.current - 90, next_due_on: Date.yesterday)
      create(:vaccine_record, vaccine_name: "口蹄疫", vaccinated_on: Date.current, next_due_on: Date.current + 60)

      expect(other_vaccine_latest.overdue?).to be true
    end
  end

  describe ".overdue / .due_soon スコープ" do
    it "同じワクチン名の最新記録のみを対象にする" do
      old_overdue = create(:vaccine_record, vaccine_name: "口蹄疫", vaccinated_on: Date.current - 90, next_due_on: Date.yesterday)
      latest = create(:vaccine_record, vaccine_name: "口蹄疫", vaccinated_on: Date.current, next_due_on: Date.current + 3)

      expect(VaccineRecord.overdue).not_to include(old_overdue)
      expect(VaccineRecord.due_soon).to include(latest)
    end
  end
end
