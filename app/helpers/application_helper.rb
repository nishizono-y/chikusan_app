module ApplicationHelper
  JA_WEEKDAYS = %w[日 月 火 水 木 金 土].freeze

  def ja_date(date)
    return nil if date.nil?
    date.strftime("%-m月%-d日（#{JA_WEEKDAYS[date.wday]}）")
  end
end
