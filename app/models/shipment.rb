class Shipment < ApplicationRecord
  validates :shipped_at, presence: true
  validates :count, presence: true, numericality: { only_integer: true, greater_than: 0, allow_blank: true }
  validates :avg_weight, presence: true, numericality: { greater_than: 0, allow_blank: true }
  validates :destination, presence: true
end
