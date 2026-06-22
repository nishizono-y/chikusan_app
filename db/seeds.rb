DailyRecord.find_or_create_by!(date: "2026-06-01") do |r|
  r.death_count = 0
  r.feed_usage  = 120
  r.feed_stock  = 400
  r.vaccine     = "なし"
  r.memo        = "特に異常なし"
end

DailyRecord.find_or_create_by!(date: "2026-06-02") do |r|
  r.death_count = 1
  r.feed_usage  = 125
  r.feed_stock  = 375
  r.vaccine     = "口蹄疫"
  r.memo        = "ワクチン接種実施"
end

Shipment.find_or_create_by!(shipped_at: "2026-06-10") do |s|
  s.count      = 50
  s.avg_weight = 480.5
  s.destination = "鹿児島市場"
end
