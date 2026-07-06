FactoryBot.define do
  factory :shipment do
    shipped_at { Date.current }
    count { 5 }
    avg_weight { "450.5" }
    destination { "鹿児島食肉センター" }
  end
end
