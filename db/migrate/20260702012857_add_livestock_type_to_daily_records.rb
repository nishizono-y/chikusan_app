class AddLivestockTypeToDailyRecords < ActiveRecord::Migration[8.1]
  def change
    add_reference :daily_records, :livestock_type, null: true, foreign_key: true
  end
end
