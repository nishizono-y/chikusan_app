FactoryBot.define do
  factory :feed_order do
    ordered_on { Date.current }
    quantity { 300 }
    supplier { "JA薩摩川内" }
    memo { "定期発注" }
  end
end
