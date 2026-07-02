class CreateLivestockTypes < ActiveRecord::Migration[8.1]
  def change
    create_table :livestock_types do |t|
      t.string :name, null: false
      t.string :unit, null: false

      t.timestamps
    end
    add_index :livestock_types, :name, unique: true
  end
end
