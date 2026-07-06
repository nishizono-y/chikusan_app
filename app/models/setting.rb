class Setting < ApplicationRecord
  FEED_STOCK_KEY = "feed_stock_threshold"
  DEFAULTS = { FEED_STOCK_KEY => 300 }.freeze

  validates :name, presence: true, uniqueness: true
  validates :value, presence: true, numericality: { only_integer: true, greater_than: 0 }

  def self.[](name)
    find_by(name: name.to_s)&.value || DEFAULTS[name.to_s]
  end

  def self.feed_stock_threshold
    self[FEED_STOCK_KEY]
  end

  def self.fetch(name)
    find_by(name: name.to_s) || create!(name: name.to_s, value: DEFAULTS[name.to_s])
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique
    find_by!(name: name.to_s)
  end
end
