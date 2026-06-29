class CreateVaccineRecords < ActiveRecord::Migration[8.1]
  def change
    create_table :vaccine_records do |t|
      t.string :vaccine_name
      t.date :vaccinated_on
      t.integer :head_count
      t.date :next_due_on
      t.text :notes

      t.timestamps
    end
  end
end
