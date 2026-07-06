FactoryBot.define do
  factory :daily_record do
    date { Date.current }
    death_count { 0 }
    feed_usage { 50 }
    feed_stock { 300 }
    vaccine { "なし" }
    memo { "特記事項なし" }
  end
end
