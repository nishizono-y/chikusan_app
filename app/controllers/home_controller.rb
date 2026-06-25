class HomeController < ApplicationController
  def index
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

    latest_record = @recent_records.first || DailyRecord.order(date: :desc).first
    stock = latest_record&.feed_stock
    if stock && stock <= DailyRecord::FEED_STOCK_ALERT_THRESHOLD
      @feed_stock_alert = true
      usage = latest_record.feed_usage.to_i
      remaining = usage > 0 ? (stock.to_f / usage).ceil : nil
      @feed_remaining_days = remaining if remaining&.positive?
    end

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
