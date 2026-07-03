class VaccineRecord < ApplicationRecord
  DUE_SOON_DAYS = 7

  validates :vaccine_name, presence: true
  validates :vaccinated_on, presence: true
  validates :head_count, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true

  before_validation :normalize_vaccine_name

  after_save :sync_daily_record_vaccine, if: -> { saved_change_to_vaccinated_on? || saved_change_to_vaccine_name? }

  LATEST_PER_VACCINE_NAME_SQL = <<~SQL.squish
    vaccine_records.id = (
      SELECT vr2.id FROM vaccine_records vr2
      WHERE vr2.vaccine_name = vaccine_records.vaccine_name
      ORDER BY vr2.vaccinated_on DESC, vr2.id DESC
      LIMIT 1
    )
  SQL

  # 同じ vaccine_name の中で最新の接種記録のみを対象にする
  scope :latest_per_vaccine_name, -> { where(LATEST_PER_VACCINE_NAME_SQL) }

  scope :overdue,   -> { latest_per_vaccine_name.where("next_due_on <= ?", Date.current) }
  scope :due_soon,  -> { latest_per_vaccine_name.where(next_due_on: (Date.current + 1)..(Date.current + DUE_SOON_DAYS)) }

  # latest_vaccine_ids を渡すと latest_per_vaccine_name の再クエリを省略できる
  # （一覧表示など、同じ判定を多数のレコードに対して行う場合に使う）
  def overdue?(latest_vaccine_ids = nil)
    next_due_on.present? && next_due_on <= Date.current && latest_for_vaccine_name?(latest_vaccine_ids)
  end

  def due_soon?(latest_vaccine_ids = nil)
    next_due_on.present? && next_due_on.between?(Date.current + 1, Date.current + DUE_SOON_DAYS) && latest_for_vaccine_name?(latest_vaccine_ids)
  end

  # 同じ vaccine_name の中でこのレコードが最新（最新の接種日、同日なら最新の id）かどうか
  def latest_for_vaccine_name?(latest_vaccine_ids = nil)
    return latest_vaccine_ids.include?(id) if latest_vaccine_ids

    return !self.class.exists?(vaccine_name: vaccine_name) if new_record?

    self.class.latest_per_vaccine_name.exists?(id: id)
  end

  private

  def normalize_vaccine_name
    self.vaccine_name = vaccine_name.strip if vaccine_name.present?
  end

  # 接種日・ワクチン名の変更を対応する日次記録に追従させる。
  # 接種日が変わったときは、このレコードが以前反映していた分に限って旧日付の日次記録を「なし」に戻す。
  # 日次記録側が別の値（このレコード由来ではない値）を保持している場合は上書きしない。
  def sync_daily_record_vaccine
    revert_previous_daily_record if saved_change_to_vaccinated_on? && vaccinated_on_before_last_save.present?
    apply_daily_record_vaccine
  end

  def revert_previous_daily_record
    daily_record = DailyRecord.find_by(date: vaccinated_on_before_last_save)
    return if daily_record.nil?

    previous_option = matched_vaccine_option(vaccine_name_before_last_save || vaccine_name)
    daily_record.update(vaccine: "なし") if daily_record.vaccine == previous_option
  end

  def apply_daily_record_vaccine
    daily_record = DailyRecord.find_by(date: vaccinated_on)
    return if daily_record.nil?

    if daily_record.vaccine_given?
      previous_option = vaccine_name_before_last_save && matched_vaccine_option(vaccine_name_before_last_save)
      return if daily_record.vaccine != previous_option
    end

    daily_record.update(vaccine: matched_vaccine_option(vaccine_name))
  end

  def matched_vaccine_option(name)
    (DailyRecord::VACCINE_OPTIONS - %w[なし]).find { |o| o == name } || "その他"
  end
end
