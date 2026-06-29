class AddNotNullConstraintsToVaccineRecords < ActiveRecord::Migration[8.1]
  def change
    change_column_null :vaccine_records, :vaccine_name, false
    change_column_null :vaccine_records, :vaccinated_on, false
  end
end
