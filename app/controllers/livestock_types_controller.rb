class LivestockTypesController < ApplicationController
  before_action :set_livestock_type, only: %i[ show edit update destroy ]

  # GET /livestock_types or /livestock_types.json
  def index
    @livestock_types = LivestockType.all
  end

  # GET /livestock_types/1 or /livestock_types/1.json
  def show
  end

  # GET /livestock_types/new
  def new
    @livestock_type = LivestockType.new
  end

  # GET /livestock_types/1/edit
  def edit
  end

  # POST /livestock_types or /livestock_types.json
  def create
    @livestock_type = LivestockType.new(livestock_type_params)

    respond_to do |format|
      if @livestock_type.save
        format.html { redirect_to @livestock_type, notice: "畜種を登録しました。" }
        format.json { render :show, status: :created, location: @livestock_type }
      else
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @livestock_type.errors, status: :unprocessable_content }
      end
    end
  end

  # PATCH/PUT /livestock_types/1 or /livestock_types/1.json
  def update
    respond_to do |format|
      if @livestock_type.update(livestock_type_params)
        format.html { redirect_to @livestock_type, notice: "畜種を更新しました。", status: :see_other }
        format.json { render :show, status: :ok, location: @livestock_type }
      else
        format.html { render :edit, status: :unprocessable_content }
        format.json { render json: @livestock_type.errors, status: :unprocessable_content }
      end
    end
  end

  # DELETE /livestock_types/1 or /livestock_types/1.json
  def destroy
    @livestock_type.destroy!

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to livestock_types_path, notice: "畜種を削除しました。", status: :see_other }
      format.json { head :no_content }
    end
  # LivestockType には has_many :daily_records, dependent: :restrict_with_error があり、
  # 紐づく日次記録が存在すると destroy! が RecordNotDestroyed を投げるため rescue が必要。
  # 他のモデル（Shipment/DailyRecord/VaccineRecord）には restrict_with_error な関連が無いため、
  # 同様の rescue は不要（過去に到達不能なデッドコードとして削除済み）。
  # 新しく restrict_with_error を追加するモデルがあれば、対応する rescue もここに倣って追加すること。
  rescue ActiveRecord::RecordNotDestroyed
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.update("flash", partial: "shared/flash_alert", locals: { message: "この畜種は日次記録で使用されているため削除できません。" }) }
      format.html { redirect_to livestock_types_path, alert: "この畜種は日次記録で使用されているため削除できません。", status: :see_other }
      format.json { head :unprocessable_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_livestock_type
      @livestock_type = LivestockType.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def livestock_type_params
      params.require(:livestock_type).permit(:name, :unit)
    end
end
