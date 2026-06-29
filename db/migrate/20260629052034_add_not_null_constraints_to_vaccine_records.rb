class AddNotNullConstraintsToVaccineRecords < ActiveRecord::Migration[8.1]
  # 適用前に NULL データがないことを確認:
  # SELECT COUNT(*) FROM vaccine_records WHERE vaccine_name IS NULL OR vaccinated_on IS NULL;
  def change
    change_column_null :vaccine_records, :vaccine_name, false
    change_column_null :vaccine_records, :vaccinated_on, false
  end
end
