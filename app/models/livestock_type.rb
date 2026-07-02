class LivestockType < ApplicationRecord
  has_many :daily_records, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: true
  validates :unit, presence: true
end
