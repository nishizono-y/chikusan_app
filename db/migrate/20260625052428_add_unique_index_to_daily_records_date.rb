class AddUniqueIndexToDailyRecordsDate < ActiveRecord::Migration[8.1]
  def change
    add_index :daily_records, :date, unique: true
  end
end
