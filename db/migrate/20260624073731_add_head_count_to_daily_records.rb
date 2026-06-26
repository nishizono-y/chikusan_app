class AddHeadCountToDailyRecords < ActiveRecord::Migration[8.1]
  def change
    add_column :daily_records, :head_count, :integer
  end
end
