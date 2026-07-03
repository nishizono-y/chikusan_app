class VaccineRecordsController < ApplicationController
  before_action :set_vaccine_record, only: %i[show edit update destroy]

  def index
    @vaccine_records = VaccineRecord.order(vaccinated_on: :desc)
  end

  def show
  end

  def new
    @vaccine_record = VaccineRecord.new(
      vaccinated_on: params[:vaccinated_on],
      vaccine_name: params[:vaccine_name]
    )
  end

  def edit
  end

  def create
    @vaccine_record = VaccineRecord.new(vaccine_record_params)
    respond_to do |format|
      if @vaccine_record.save
        format.html { redirect_to @vaccine_record, notice: "接種記録を登録しました。" }
      else
        format.html { render :new, status: :unprocessable_content }
      end
    end
  end

  def update
    respond_to do |format|
      if @vaccine_record.update(vaccine_record_params)
        format.html { redirect_to @vaccine_record, notice: "接種記録を更新しました。" }
      else
        format.html { render :edit, status: :unprocessable_content }
      end
    end
  end

  def destroy
    @vaccine_record.destroy!
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to vaccine_records_path, notice: "接種記録を削除しました。", status: :see_other }
    end
  rescue ActiveRecord::RecordNotDestroyed
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.update("flash", partial: "shared/flash_alert", locals: { message: "接種記録を削除できませんでした。" }) }
      format.html { redirect_to vaccine_records_path, alert: "接種記録を削除できませんでした。", status: :see_other }
    end
  end

  private

  def set_vaccine_record
    @vaccine_record = VaccineRecord.find(params[:id])
  end

  def vaccine_record_params
    params.require(:vaccine_record).permit(:vaccine_name, :vaccinated_on, :head_count, :next_due_on, :notes)
  end
end
