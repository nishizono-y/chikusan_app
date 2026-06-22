FactoryBot.define do
  factory :daily_record do
    date { "2026-06-18" }
    death_count { 1 }
    feed_usage { 1 }
    feed_stock { 1 }
    vaccine { "なし" }
    memo { "MyText" }
  end
end
