class VaccineRecord < ApplicationRecord
  DUE_SOON_DAYS = 7

  validates :vaccine_name, presence: true
  validates :vaccinated_on, presence: true
  validates :head_count, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true

  after_save :sync_daily_record_vaccine

  scope :overdue,   -> { where("next_due_on <= ?", Date.current) }
  scope :due_soon,  -> { where(next_due_on: (Date.current + 1)..(Date.current + DUE_SOON_DAYS)) }

  def overdue?
    next_due_on.present? && next_due_on <= Date.current
  end

  def due_soon?
    next_due_on.present? && next_due_on.between?(Date.current + 1, Date.current + DUE_SOON_DAYS)
  end

  private

  # 接種日と同じ日付の日次記録がまだワクチン「なし」のままなら、
  # ワクチン名が畜種の選択肢と一致すればそれを、一致しなければ「その他」を自動で反映する。
  def sync_daily_record_vaccine
    daily_record = DailyRecord.find_by(date: vaccinated_on)
    return if daily_record.nil? || daily_record.vaccine_given?

    option = (DailyRecord::VACCINE_OPTIONS - %w[なし]).find { |o| o == vaccine_name } || "その他"
    daily_record.update(vaccine: option)
  end
end
