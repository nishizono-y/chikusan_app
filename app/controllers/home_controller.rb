class HomeController < ApplicationController
  def index
    @weather = fetch_weather

    month_range = @today.beginning_of_month..@today.end_of_month

    @month_label = @today.strftime("%-m月")

    scope = DailyRecord.where(date: month_range)
    deaths, feed_usage = scope.pick(Arel.sql("SUM(death_count), SUM(feed_usage)"))
    @month_deaths      = deaths.to_i
    @month_feed_usage  = feed_usage.to_i
    @month_ship_count  = Shipment.where(shipped_at: month_range).sum(:count)

    ordered_scope      = scope.order(date: :desc)
    @recent_records    = ordered_scope.limit(3).load
    @month_head_count  = @recent_records.first&.head_count

    latest_record = @recent_records.first
    if latest_record
      threshold = Setting.feed_stock_threshold
      if latest_record.feed_stock_low?(threshold)
        if FeedOrder.ordered_since?(latest_record.date)
          @feed_ordered = true
        else
          @feed_stock_alert = true
          @feed_remaining_days = latest_record.estimated_remaining_days(threshold)
        end
      end
    end

    @vaccine_alerts = VaccineRecord.overdue.or(VaccineRecord.due_soon).order(:next_due_on).load
    @latest_vaccine_ids = @vaccine_alerts.map(&:id).to_set

    chart_start = 5.months.ago.beginning_of_month
    chart_records = DailyRecord
      .where(date: chart_start..@today.end_of_month)
      .order(:date)

    monthly = chart_records
      .group_by { |r| r.date.beginning_of_month }
      .transform_keys { |d| d.strftime("%Y年%-m月") }

    @chart_head_count  = monthly.transform_values { |rs| rs.max_by(&:date)&.head_count }
    @chart_death_count = monthly.transform_values { |rs| rs.sum { |r| r.death_count.to_i } }
  end

  private

    # 取得成功時は15分、失敗時（API障害など）は1分だけキャッシュする。
    # 失敗結果を長くキャッシュすると、API復旧後も天気が表示されない状態が長引くため。
    def fetch_weather
      lat = Setting.farm_lat
      lon = Setting.farm_lon
      cache_key = "weather:#{lat}:#{lon}"
      return Rails.cache.read(cache_key) if Rails.cache.exist?(cache_key)

      weather = WeatherService.fetch(lat:, lon:)
      Rails.cache.write(cache_key, weather, expires_in: weather ? 15.minutes : 1.minute)
      weather
    end
end
