class DailyRecord < ApplicationRecord
  VACCINE_OPTIONS = %w[なし 口蹄疫 ブルセラ その他].freeze

  validates :date, presence: true
  validates :death_count, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0, allow_blank: true }
  validates :feed_usage, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0, allow_blank: true }
  validates :feed_stock, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0, allow_blank: true }
  validates :vaccine, inclusion: { in: VACCINE_OPTIONS }, allow_blank: true
end
