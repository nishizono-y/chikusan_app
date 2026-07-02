class FeedOrdersController < ApplicationController
  before_action :set_feed_order, only: %i[ show edit update destroy ]

  # GET /feed_orders or /feed_orders.json
  def index
    @feed_orders = FeedOrder.order(ordered_on: :desc)
  end

  # GET /feed_orders/1 or /feed_orders/1.json
  def show
  end

  # GET /feed_orders/new
  def new
    @feed_order = FeedOrder.new(ordered_on: @today)
  end

  # GET /feed_orders/1/edit
  def edit
  end

  # POST /feed_orders or /feed_orders.json
  def create
    @feed_order = FeedOrder.new(feed_order_params)

    respond_to do |format|
      if @feed_order.save
        format.html { redirect_to @feed_order, notice: "発注記録を登録しました。" }
        format.json { render :show, status: :created, location: @feed_order }
      else
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @feed_order.errors, status: :unprocessable_content }
      end
    end
  end

  # PATCH/PUT /feed_orders/1 or /feed_orders/1.json
  def update
    respond_to do |format|
      if @feed_order.update(feed_order_params)
        format.html { redirect_to @feed_order, notice: "発注記録を更新しました。", status: :see_other }
        format.json { render :show, status: :ok, location: @feed_order }
      else
        format.html { render :edit, status: :unprocessable_content }
        format.json { render json: @feed_order.errors, status: :unprocessable_content }
      end
    end
  end

  # DELETE /feed_orders/1 or /feed_orders/1.json
  def destroy
    @feed_order.destroy!

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to feed_orders_path, notice: "発注記録を削除しました。", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_feed_order
      @feed_order = FeedOrder.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def feed_order_params
      params.require(:feed_order).permit(:ordered_on, :quantity, :supplier, :memo)
    end
end
