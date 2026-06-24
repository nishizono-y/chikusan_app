class ReportsController < ApplicationController
  def index
    @target = params[:month].present? ? Date.parse("#{params[:month]}-01") : Date.current.beginning_of_month
    month_range = @target.beginning_of_month..@target.end_of_month
    prev_range  = (@target - 1.month).beginning_of_month..(@target - 1.month).end_of_month

    @month_label = @target.strftime("%-m月")

    daily_scope = DailyRecord.where(date: month_range)
    deaths, feed_total = daily_scope.pick(Arel.sql("SUM(death_count), SUM(feed_usage)"))
    @deaths     = deaths.to_i
    @feed_total = feed_total.to_i

    @month_start_count = daily_scope.order(:date).pick(:head_count)
    @month_end_count   = daily_scope.order(date: :desc).pick(:head_count)
    @mortality_rate    = (@month_start_count.to_i > 0) ? (@deaths.to_f / @month_start_count * 100).round(1) : nil

    ship_scope         = Shipment.where(shipped_at: month_range).order(:shipped_at)
    @ship_count        = ship_scope.sum(:count)
    @ship_total_weight = ship_scope.sum(Arel.sql("count * avg_weight")).to_f.round(1)
    @shipments         = ship_scope.load

    @feed_days = daily_scope.count
    @feed_per_head_day = (@feed_days > 0 && @month_start_count.to_i > 0) ? (@feed_total.to_f / @feed_days / @month_start_count).round(1) : nil

    prev_feed = DailyRecord.where(date: prev_range).sum(:feed_usage).to_i
    @feed_vs_prev = prev_feed > 0 ? @feed_total - prev_feed : nil

    @memos = daily_scope.where.not(memo: [nil, ""]).order(:date).pluck(:date, :memo)
  end
end
