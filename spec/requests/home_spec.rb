require "rails_helper"

RSpec.describe "/", type: :request do
  describe "GET /" do
    it "200を返す" do
      get root_path
      expect(response).to have_http_status(:ok)
    end

    it "当月の日次記録だけを集計する" do
      create_daily_record(date: Date.current, death_count: 2, feed_usage: 100)
      create_daily_record(date: Date.current.prev_month, death_count: 99, feed_usage: 9999)

      get root_path

      expect(response.body).to include("2")
      expect(response.body).not_to include("99")
    end

    it "当月の出荷記録だけを集計する" do
      create_shipment(shipped_at: Date.current, count: 5)
      create_shipment(shipped_at: Date.current.prev_month, count: 999)

      get root_path

      expect(response.body).to include("5")
      expect(response.body).not_to include("999")
    end

    it "直近3件の日次記録を表示する" do
      4.times { |i| create_daily_record(date: Date.current.beginning_of_month + i.days) }

      get root_path

      expect(response.body.scan("record-item").length).to eq(3)
    end

    it "レコードがない場合も正常に表示される" do
      DailyRecord.delete_all
      Shipment.delete_all

      get root_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("まだ記録がありません")
    end
  end

  private

  def create_daily_record(attrs = {})
    DailyRecord.create!(
      { date: Date.current, death_count: 0, feed_usage: 100, feed_stock: 500, vaccine: "なし" }.merge(attrs)
    )
  end

  def create_shipment(attrs = {})
    Shipment.create!(
      { shipped_at: Date.current, count: 1, avg_weight: 110.0, destination: "テスト先" }.merge(attrs)
    )
  end
end
