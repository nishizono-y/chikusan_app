class ShipmentsController < ApplicationController
  before_action :set_shipment, only: %i[ show edit update destroy ]

  # GET /shipments or /shipments.json
  def index
    @shipments = Shipment.all
  end

  # GET /shipments/1 or /shipments/1.json
  def show
  end

  # GET /shipments/new
  def new
    @shipment = Shipment.new
  end

  # GET /shipments/1/edit
  def edit
  end

  # POST /shipments or /shipments.json
  def create
    @shipment = Shipment.new(shipment_params)

    respond_to do |format|
      if @shipment.save
        format.html { redirect_to @shipment, notice: "出荷記録を登録しました。" }
        format.json { render :show, status: :created, location: @shipment }
      else
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @shipment.errors, status: :unprocessable_content }
      end
    end
  end

  # PATCH/PUT /shipments/1 or /shipments/1.json
  def update
    respond_to do |format|
      if @shipment.update(shipment_params)
        format.html { redirect_to @shipment, notice: "出荷記録を更新しました。", status: :see_other }
        format.json { render :show, status: :ok, location: @shipment }
      else
        format.html { render :edit, status: :unprocessable_content }
        format.json { render json: @shipment.errors, status: :unprocessable_content }
      end
    end
  end

  # DELETE /shipments/1 or /shipments/1.json
  def destroy
    @shipment.destroy!

    respond_to do |format|
      format.html { redirect_to shipments_path, notice: "出荷記録を削除しました。", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_shipment
      @shipment = Shipment.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def shipment_params
      params.require(:shipment).permit(:shipped_at, :count, :avg_weight, :destination)
    end
end
