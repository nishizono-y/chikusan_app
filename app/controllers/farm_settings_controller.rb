class FarmSettingsController < ApplicationController
  # GET /farm_settings/edit
  def edit
    @lat_setting = Setting.fetch(Setting::FARM_LAT_KEY)
    @lon_setting = Setting.fetch(Setting::FARM_LON_KEY)
  end

  # PATCH /farm_settings
  def update
    @lat_setting = Setting.fetch(Setting::FARM_LAT_KEY)
    @lon_setting = Setting.fetch(Setting::FARM_LON_KEY)
    @lat_setting.value = farm_settings_params[:lat]
    @lon_setting.value = farm_settings_params[:lon]

    # 緯度・経度のどちらかが不正な場合に片方だけ保存されないよう、まとめてロールバックする。
    # `&&` で短絡させると経度が不正な場合に #save が呼ばれず、エラーが表示されなくなるため
    # 両方の #save を必ず実行してから結果をまとめて判定する。
    saved = Setting.transaction do
      lat_saved = @lat_setting.save
      lon_saved = @lon_setting.save
      raise ActiveRecord::Rollback unless lat_saved && lon_saved
      true
    end

    if saved
      redirect_to edit_farm_settings_path, notice: "農場設定を保存しました。"
    else
      render :edit, status: :unprocessable_content
    end
  end

  private
    def farm_settings_params
      params.require(:farm_settings).permit(:lat, :lon)
    end
end
