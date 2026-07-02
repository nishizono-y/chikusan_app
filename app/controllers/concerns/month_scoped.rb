module MonthScoped
  extend ActiveSupport::Concern

  private

  # params[:month]（"YYYY-MM"形式）を月初日のDateにパースする。
  # 未指定または不正な形式の場合は当月にフォールバックする。
  def parse_target_month
    params[:month].present? ? Date.parse("#{params[:month]}-01") : Date.current.beginning_of_month
  rescue Date::Error
    Date.current.beginning_of_month
  end
end
