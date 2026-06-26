class SettingsController < ApplicationController
  before_action :set_setting

  def edit
  end

  def update
    if @setting.update(setting_params)
      redirect_to edit_setting_path, notice: "設定を保存しました"
    else
      render :edit, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotUnique
    @setting = Setting.fetch(Setting::FEED_STOCK_KEY)
    retry
  end

  private

  def set_setting
    @setting = Setting.fetch(Setting::FEED_STOCK_KEY)
  end

  def setting_params
    params.require(:setting).permit(:value)
  end
end
