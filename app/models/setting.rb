class Setting < ApplicationRecord
  DEFAULT_FEED_STOCK_THRESHOLD = 300

  validates :feed_stock_threshold, presence: true,
    numericality: { only_integer: true, greater_than: 0 }

  def self.feed_stock_threshold
    first&.feed_stock_threshold || DEFAULT_FEED_STOCK_THRESHOLD
  end

  def self.instance
    first_or_initialize
  end
end
