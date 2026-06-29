class VaccineRecord < ApplicationRecord
  DUE_SOON_DAYS = 7

  validates :vaccine_name, presence: true
  validates :vaccinated_on, presence: true
  validates :head_count, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true

  scope :overdue,   -> { where("next_due_on <= ?", Date.current) }
  scope :due_soon,  -> { where(next_due_on: (Date.current + 1)..DUE_SOON_DAYS.days.from_now.to_date) }

  def overdue?
    next_due_on.present? && next_due_on <= Date.current
  end

  def due_soon?
    next_due_on.present? && next_due_on.between?(Date.current + 1, DUE_SOON_DAYS.days.from_now.to_date)
  end
end
