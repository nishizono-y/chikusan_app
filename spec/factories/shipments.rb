FactoryBot.define do
  factory :shipment do
    shipped_at { "2026-06-18" }
    count { 1 }
    avg_weight { "9.99" }
    destination { "MyString" }
  end
end
