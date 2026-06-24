class HomeController < ApplicationController
  def index
    today = Date.current
    month_range = today.beginning_of_month..today.end_of_month

    @month_label = today.strftime("%-m月")
    @today_label = today.strftime("%-m月%-d日（#{%w[日 月 火 水 木 金 土][today.wday]}）")

    @month_deaths      = DailyRecord.where(date: month_range).sum(:death_count)
    @month_ship_count  = Shipment.where(shipped_at: month_range).sum(:count)
    @month_feed_usage  = DailyRecord.where(date: month_range).sum(:feed_usage)

    @recent_records    = DailyRecord.order(date: :desc).limit(3)
  end
end
