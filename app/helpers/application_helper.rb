module ApplicationHelper
  include Chartkick::Helper
  # 年なし・曜日付き（ホーム画面など当月限定のコンテキスト向け）
  def ja_date(date)
    return nil if date.nil?
    l(date, format: :home)
  end

  # 年あり・曜日なし（一覧・詳細など複数年にわたるコンテキスト向け）
  def ja_date_full(date)
    return nil if date.nil?
    date.strftime("%Y年%-m月%-d日")
  end
end
