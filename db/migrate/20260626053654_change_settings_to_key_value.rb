class ChangeSettingsToKeyValue < ActiveRecord::Migration[8.1]
  def change
    remove_column :settings, :feed_stock_threshold
    add_column :settings, :name, :string, null: false, default: ""
    add_column :settings, :value, :integer, null: false, default: 0
    add_index :settings, :name, unique: true
  end
end
