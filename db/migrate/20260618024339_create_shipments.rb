class CreateShipments < ActiveRecord::Migration[7.2]
  def change
    create_table :shipments do |t|
      t.date :shipped_at
      t.integer :count
      t.decimal :avg_weight
      t.string :destination

      t.timestamps
    end
  end
end
