class FixSettingsValueDefault < ActiveRecord::Migration[8.1]
  def change
    change_column_default :settings, :value, from: 0, to: nil
  end
end
