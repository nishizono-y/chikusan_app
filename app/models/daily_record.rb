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

  # 死亡率の異常検知アラートを返す。
  # 直近 days 日間の平均死亡率と比較し、当日が 2 倍以上なら警告、3 倍以上なら要注意を返す。
  # 平均死亡率がゼロ（過去に死亡ゼロ）の場合は比較不能として nil を返す。
  def self.mortality_alert(today_record, days: 30)
    return nil unless today_record&.head_count.to_i > 0
    return nil unless today_record.death_count.to_i > 0

    today_rate = today_record.death_count.to_f / today_record.head_count

    past = where.not(id: today_record.id)
                .where(date: (today_record.date - days.days)...(today_record.date))
                .where("head_count > 0")
    total_head = past.sum(:head_count)
    return nil unless total_head > 0

    avg_rate = past.sum(:death_count).to_f / total_head
    return nil unless avg_rate > 0

    ratio = today_rate / avg_rate
    return nil unless ratio >= 2

    level = ratio >= 3 ? :danger : :warning
    { level: level, ratio: ratio.round(1), days: days }
  end
end
