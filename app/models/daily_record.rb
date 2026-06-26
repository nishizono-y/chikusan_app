class DailyRecord < ApplicationRecord
  VACCINE_OPTIONS = %w[なし 口蹄疫 ブルセラ その他].freeze
  FEED_STOCK_ALERT_THRESHOLD = 300

  validates :date, presence: true, uniqueness: true
  validates :death_count, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0, allow_blank: true }
  validates :feed_usage, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0, allow_blank: true }
  validates :feed_stock, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0, allow_blank: true }
  validates :vaccine, inclusion: { in: VACCINE_OPTIONS }, allow_blank: true

  def feed_stock_low?
    feed_stock && feed_stock <= FEED_STOCK_ALERT_THRESHOLD
  end

  # nil を返すケースが2種ある:
  #   1. 在庫がしきい値超 (feed_stock_low? == false)
  #   2. 在庫はゼロ or feed_usage がゼロで計算不能
  # アラート表示との分離が必要な呼び出し元は feed_stock_low? を先にチェックすること。
  # 内部で feed_stock_low? を再チェックしているのは、コントローラー以外からの直接呼び出しを安全にするため。
  def estimated_remaining_days
    return nil unless feed_stock_low?
    usage = feed_usage.to_i
    return nil unless usage > 0
    remaining = feed_stock.fdiv(usage).ceil
    remaining if remaining.positive?
  end
end
