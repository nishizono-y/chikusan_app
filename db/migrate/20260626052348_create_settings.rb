class CreateSettings < ActiveRecord::Migration[8.1]
  def change
    create_table :settings do |t|
      t.integer :feed_stock_threshold, null: false, default: 300

      t.timestamps
    end
  end
end
