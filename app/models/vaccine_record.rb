class VaccineRecord < ApplicationRecord
  validates :vaccine_name, presence: true
  validates :vaccinated_on, presence: true
  validates :head_count, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true

  scope :upcoming, -> { where(next_due_on: ..7.days.from_now).where("next_due_on >= ?", Date.today) }
  scope :overdue, -> { where("next_due_on < ?", Date.today) }
  scope :due_soon, -> { where(next_due_on: Date.today..7.days.from_now) }

  def overdue?
    next_due_on.present? && next_due_on < Date.today
  end

  def due_soon?
    next_due_on.present? && next_due_on.between?(Date.today, 7.days.from_now.to_date)
  end
end
