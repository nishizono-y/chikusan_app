class ChangeSettingsValueToDecimal < ActiveRecord::Migration[8.1]
  def up
    change_column :settings, :value, :decimal, precision: 9, scale: 6, null: false
  end

  def down
    change_column :settings, :value, :integer, null: false
  end
end
