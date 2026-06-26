class SettingsController < ApplicationController
  def edit
    @setting = Setting.instance
  end

  def update
    @setting = Setting.instance
    if @setting.update(setting_params)
      redirect_to edit_setting_path, notice: "設定を保存しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def setting_params
    params.require(:setting).permit(:feed_stock_threshold)
  end
end
