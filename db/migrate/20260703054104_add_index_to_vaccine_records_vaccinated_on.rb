class AddIndexToVaccineRecordsVaccinatedOn < ActiveRecord::Migration[8.1]
  def change
    add_index :vaccine_records, :vaccinated_on
  end
end
