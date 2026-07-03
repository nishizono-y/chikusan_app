class AddIndexToFeedOrdersOrderedOn < ActiveRecord::Migration[8.1]
  def change
    add_index :feed_orders, :ordered_on
  end
end
