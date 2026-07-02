class CreateFeedOrders < ActiveRecord::Migration[8.1]
  def change
    create_table :feed_orders do |t|
      t.date :ordered_on, null: false
      t.integer :quantity, null: false
      t.string :supplier, null: false
      t.text :memo

      t.timestamps
    end
  end
end
