class DailyRecordsController < ApplicationController
  before_action :set_daily_record, only: %i[ show edit update destroy ]

  # GET /daily_records or /daily_records.json
  def index
    @daily_records = DailyRecord.all
    today_record = DailyRecord.find_by(date: Date.current)
    @mortality_alert = DailyRecord.mortality_alert(today_record)
  end

  # GET /daily_records/1 or /daily_records/1.json
  def show
  end

  # GET /daily_records/new
  def new
    @daily_record = DailyRecord.new
  end

  # GET /daily_records/1/edit
  def edit
  end

  # POST /daily_records or /daily_records.json
  def create
    @daily_record = DailyRecord.new(daily_record_params)

    respond_to do |format|
      if @daily_record.save
        format.html { redirect_to @daily_record, notice: "日次記録を登録しました。" }
        format.json { render :show, status: :created, location: @daily_record }
      else
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
      format.html { redirect_to daily_records_path, notice: "日次記録を削除しました。", status: :see_other }
      format.json { head :no_content }
    end
  rescue ActiveRecord::RecordNotDestroyed
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.update("flash", partial: "shared/flash_alert", locals: { message: "日次記録を削除できませんでした。" }) }
      format.html { redirect_to daily_records_path, alert: "日次記録を削除できませんでした。", status: :see_other }
      format.json { head :unprocessable_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_daily_record
      @daily_record = DailyRecord.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def daily_record_params
      params.require(:daily_record).permit(:date, :head_count, :death_count, :feed_usage, :feed_stock, :vaccine, :memo)
    end
end
