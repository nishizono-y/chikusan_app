class Setting < ApplicationRecord
  FEED_STOCK_KEY = "feed_stock_threshold"
  FARM_LAT_KEY = "farm_lat"
  FARM_LON_KEY = "farm_lon"

  DEFAULTS = {
    FEED_STOCK_KEY => 300,
    # 薩摩川内市（鹿児島）。農場設定が未保存の場合のフォールバック値。
    FARM_LAT_KEY => 31.8159,
    FARM_LON_KEY => 130.3006
  }.freeze

  # name の一意性は DB のユニークインデックス（index_settings_on_name）のみで担保する。
  # アプリ側でも uniqueness: true を課すと、#fetch で create_or_find_by! を使う際に
  # 「既に存在する」通常ケースでも RecordInvalid が発生し、レース対策の rescue
  # （RecordNotUnique のみを想定）で拾えなくなってしまうため。
  validates :name, presence: true
  validates :value, presence: true
  validates :value, numericality: { only_integer: true, greater_than: 0 }, if: -> { name == FEED_STOCK_KEY }
  validates :value, numericality: { greater_than_or_equal_to: -90, less_than_or_equal_to: 90 }, if: -> { name == FARM_LAT_KEY }
  validates :value, numericality: { greater_than_or_equal_to: -180, less_than_or_equal_to: 180 }, if: -> { name == FARM_LON_KEY }

  def self.[](name)
    find_by(name: name.to_s)&.value || DEFAULTS[name.to_s]
  end

  def self.feed_stock_threshold
    self[FEED_STOCK_KEY]
  end

  def self.farm_lat
    self[FARM_LAT_KEY]
  end

  def self.farm_lon
    self[FARM_LON_KEY]
  end

  def self.fetch(name, attempt: 0)
    create_or_find_by!(name: name.to_s) { |s| s.value = DEFAULTS[name.to_s] }
  rescue ActiveRecord::StatementTimeout
    # SQLiteのロック競合（busy_timeout超過）用の救済策。一度だけ再試行する。
    raise if attempt >= 1
    fetch(name, attempt: attempt + 1)
  end
end
