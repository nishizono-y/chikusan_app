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
  end
end
