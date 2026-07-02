class HomeController < ApplicationController
  # 薩摩川内市（鹿児島）
  FARM_LAT = 31.8159
  FARM_LON = 130.3006

  def index
    @weather = WeatherService.fetch(lat: FARM_LAT, lon: FARM_LON)

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
        if FeedOrder.where(ordered_on: latest_record.date..).exists?
          @feed_ordered = true
        else
          @feed_stock_alert = true
          @feed_remaining_days = latest_record.estimated_remaining_days(threshold)
        end
      end
    end

    @vaccine_alerts = VaccineRecord.overdue.or(VaccineRecord.due_soon).order(:next_due_on).load

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
end
