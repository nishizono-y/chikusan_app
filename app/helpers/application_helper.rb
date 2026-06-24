module ApplicationHelper
  JA_WEEKDAYS = %w[日 月 火 水 木 金 土].freeze

  # 年なし・曜日付き（ホーム画面など当月限定のコンテキスト向け）
  def ja_date(date)
    return nil if date.nil?
    date.strftime("%-m月%-d日（#{JA_WEEKDAYS[date.wday]}）")
  end

  # 年あり・曜日なし（一覧・詳細など複数年にわたるコンテキスト向け）
  def ja_date_full(date)
    return nil if date.nil?
    date.strftime("%Y年%-m月%-d日")
  end
end
