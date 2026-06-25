class DailyRecord < ApplicationRecord
  VACCINE_OPTIONS = %w[なし 口蹄疫 ブルセラ その他].freeze
  FEED_STOCK_ALERT_THRESHOLD = 300

  validates :date, presence: true
  validates :death_count, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0, allow_blank: true }
  validates :feed_usage, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0, allow_blank: true }
  validates :feed_stock, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0, allow_blank: true }
  validates :vaccine, inclusion: { in: VACCINE_OPTIONS }, allow_blank: true

  def feed_stock_low?
    feed_stock && feed_stock <= FEED_STOCK_ALERT_THRESHOLD
  end

  def estimated_remaining_days
    return nil unless feed_stock_low?
    usage = feed_usage.to_i
    return nil unless usage > 0
    remaining = feed_stock.fdiv(usage).ceil
    remaining if remaining.positive?
  end
end
