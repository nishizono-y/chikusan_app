class Setting < ApplicationRecord
  DEFAULTS = { "feed_stock_threshold" => 300 }.freeze

  validates :name, presence: true, uniqueness: true
  validates :value, presence: true, numericality: { only_integer: true, greater_than: 0 }

  def self.[](name)
    find_by(name: name.to_s)&.value || DEFAULTS[name.to_s]
  end

  def self.feed_stock_threshold
    self["feed_stock_threshold"]
  end

  def self.fetch(name)
    find_or_initialize_by(name: name.to_s).tap do |s|
      s.value = DEFAULTS[name.to_s] unless s.persisted?
    end
  end
end
