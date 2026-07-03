class DailyRecordsController < ApplicationController
  include MonthScoped

  before_action :set_daily_record, only: %i[ show edit update destroy ]

  # GET /daily_records or /daily_records.json
  def index
    @target = parse_target_month
    month_range = @target..@target.end_of_month

    @month_label = @target.strftime("%Y年%-m月")
    @prev_month  = (@target - 1.month).strftime("%Y-%m")
    @next_month  = (@target + 1.month).strftime("%Y-%m")

    @daily_records = DailyRecord.where(date: month_range).order(:date)
    today_record = DailyRecord.find_by(date: Date.current)
    @mortality_alert = DailyRecord.mortality_alert(today_record)
  end

  # GET /daily_records/1 or /daily_records/1.json
  def show
    @related_vaccine_records = VaccineRecord.where(vaccinated_on: @daily_record.date).order(:id) if @daily_record.vaccine_given?
  end

  # GET /daily_records/new
  def new
    prev = fetch_prev_record(before_date: Date.tomorrow)
    @daily_record = DailyRecord.new
    if prev
      @daily_record.livestock_type_id = prev.livestock_type_id
      @daily_record.head_count = [ (prev.head_count || 0) - (prev.death_count || 0), 0 ].max
      @daily_record.feed_stock = prev.feed_stock
      @prev_feed_stock = prev.feed_stock
      @auto_calculated_head_count = true
    end
  end

  # GET /daily_records/1/edit
  def edit
    prev = fetch_prev_record(before_date: @daily_record.date)
    @prev_feed_stock = prev.feed_stock if prev
  end

  # POST /daily_records or /daily_records.json
  def create
    @daily_record = DailyRecord.new(daily_record_params)

    respond_to do |format|
      if @daily_record.save
        format.html { redirect_to @daily_record, notice: "日次記録を登録しました。" }
        format.json { render :show, status: :created, location: @daily_record }
      else
        before_date = @daily_record.date || Date.tomorrow
        prev = fetch_prev_record(before_date: before_date)
        @prev_feed_stock = prev.feed_stock if prev
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @daily_record.errors, status: :unprocessable_content }
      end
    end
  end

  # PATCH/PUT /daily_records/1 or /daily_records/1.json
  def update
    respond_to do |format|
      if @daily_record.update(daily_record_params)
        format.html { redirect_to @daily_record, notice: "日次記録を更新しました。", status: :see_other }
        format.json { render :show, status: :ok, location: @daily_record }
      else
        prev = fetch_prev_record(before_date: @daily_record.date)
        @prev_feed_stock = prev.feed_stock if prev
        format.html { render :edit, status: :unprocessable_content }
        format.json { render json: @daily_record.errors, status: :unprocessable_content }
      end
    end
  end

  # DELETE /daily_records/1 or /daily_records/1.json
  def destroy
    @daily_record.destroy!

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to daily_records_path(month: daily_record_month), notice: "日次記録を削除しました。", status: :see_other }
      format.json { head :no_content }
    end
  rescue ActiveRecord::RecordNotDestroyed
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.update("flash", partial: "shared/flash_alert", locals: { message: "日次記録を削除できませんでした。" }) }
      format.html { redirect_to daily_records_path(month: daily_record_month), alert: "日次記録を削除できませんでした。", status: :see_other }
      format.json { head :unprocessable_content }
    end
  end

  helper_method :daily_record_month

  private
    def set_daily_record
      @daily_record = DailyRecord.find(params[:id])
    end

    def daily_record_month
      @daily_record.date&.strftime("%Y-%m")
    end

    def daily_record_params
      params.require(:daily_record).permit(:date, :livestock_type_id, :head_count, :death_count, :feed_usage, :feed_stock, :vaccine, :memo)
    end

    def fetch_prev_record(before_date:)
      DailyRecord.where("date < ?", before_date).order(date: :desc).first
    end
end
