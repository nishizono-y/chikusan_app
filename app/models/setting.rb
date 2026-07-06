class Setting < ApplicationRecord
  FEED_STOCK_KEY = "feed_stock_threshold"
  DEFAULTS = { FEED_STOCK_KEY => 300 }.freeze

  # name の一意性は DB のユニークインデックス（index_settings_on_name）のみで担保する。
  # アプリ側でも uniqueness: true を課すと、#fetch で create_or_find_by! を使う際に
  # 「既に存在する」通常ケースでも RecordInvalid が発生し、レース対策の rescue
  # （RecordNotUnique のみを想定）で拾えなくなってしまうため。
  validates :name, presence: true
  validates :value, presence: true, numericality: { only_integer: true, greater_than: 0 }

  def self.[](name)
    find_by(name: name.to_s)&.value || DEFAULTS[name.to_s]
  end

  def self.feed_stock_threshold
    self[FEED_STOCK_KEY]
  end

  def self.fetch(name, attempt: 0)
    create_or_find_by!(name: name.to_s) { |s| s.value = DEFAULTS[name.to_s] }
  rescue ActiveRecord::StatementTimeout
    # SQLiteのロック競合（busy_timeout超過）用の救済策。一度だけ再試行する。
    raise if attempt >= 1
    fetch(name, attempt: attempt + 1)
  end
end
