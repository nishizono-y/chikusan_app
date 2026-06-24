class HomeController < ApplicationController
  def index
    today = Date.current
    month_range = today.beginning_of_month..today.end_of_month

    @month_label = today.strftime("%-m月")

    deaths, feed_usage = DailyRecord.where(date: month_range)
                                    .pick(Arel.sql("SUM(death_count), SUM(feed_usage)"))
    @month_deaths      = deaths.to_i
    @month_feed_usage  = feed_usage.to_i
    @month_ship_count  = Shipment.where(shipped_at: month_range).sum(:count)

    @recent_records    = DailyRecord.order(date: :desc).limit(3).load
  end
end
