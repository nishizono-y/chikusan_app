class CreateDailyRecords < ActiveRecord::Migration[7.2]
  def change
    create_table :daily_records do |t|
      t.date :date
      t.integer :death_count
      t.integer :feed_usage
      t.integer :feed_stock
      t.string :vaccine
      t.text :memo

      t.timestamps
    end
  end
end
