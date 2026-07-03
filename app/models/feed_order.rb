class FeedOrder < ApplicationRecord
  validates :ordered_on, presence: true
  validates :quantity, presence: true, numericality: { only_integer: true, greater_than: 0, allow_blank: true }
  validates :supplier, presence: true

  def self.ordered_since?(date)
    where(ordered_on: date..).exists?
  end
end
