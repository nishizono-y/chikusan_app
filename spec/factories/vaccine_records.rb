FactoryBot.define do
  factory :vaccine_record do
    vaccine_name { "FMD vaccine" }
    vaccinated_on { Date.today - 30 }
    head_count { 50 }
    next_due_on { Date.today + 60 }
    notes { nil }
  end
end
