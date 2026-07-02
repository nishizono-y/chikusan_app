FactoryBot.define do
  factory :livestock_type do
    sequence(:name) { |n| "肉用牛#{n}" }
    unit { "頭" }
  end
end
