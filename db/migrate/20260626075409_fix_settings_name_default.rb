class FixSettingsNameDefault < ActiveRecord::Migration[8.1]
  def change
    change_column_default :settings, :name, from: "", to: nil
  end
end
