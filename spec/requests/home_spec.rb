require "rails_helper"

RSpec.describe "/", type: :request do
  describe "GET /" do
    it "200を返す" do
      get root_path
      expect(response).to have_http_status(:ok)
    end

    it "当月の日次記録だけを集計する" do
      create_daily_record(date: Date.current, death_count: 73, feed_usage: 100)
      create_daily_record(date: Date.current.prev_month, death_count: 99, feed_usage: 9999)

      get root_path

      expect(response.body).to include("73")
      expect(response.body).not_to include("99")
    end

    it "当月の出荷記録だけを集計する" do
      create_shipment(shipped_at: Date.current, count: 47)
      create_shipment(shipped_at: Date.current.prev_month, count: 999)

      get root_path

      expect(response.body).to include("47")
      expect(response.body).not_to include("999")
    end

    it "直近3件の日次記録を新しい順で表示する" do
      DailyRecord.delete_all
      base = Date.current.beginning_of_month
      4.times { |i| create_daily_record(date: base + i.days) }

      get root_path

      expect(response.body.scan("record-item").length).to eq(3)
      expect(response.body).to include((base + 3.days).strftime("%-m月%-d日"))
      expect(response.body).not_to include(base.strftime("%-m月%-d日"))
    end

    it "レコードがない場合も正常に表示される" do
      DailyRecord.delete_all
      Shipment.delete_all

      get root_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("今月はまだ記録がありません")
    end

    context "飼料残量アラート" do
      before { DailyRecord.delete_all }

      it "feed_stockがしきい値以下のときアラートバーを表示する" do
        create_daily_record(feed_stock: 300, feed_usage: 100)

        get root_path

        expect(response.body).to include("alert-bar")
        expect(response.body).to include("飼料残量が少なくなっています")
      end

      it "残日数を計算して表示する" do
        create_daily_record(feed_stock: 200, feed_usage: 50)

        get root_path

        expect(response.body).to include("残り4日分程度")
      end

      it "feed_stockがしきい値を超えているときアラートバーを表示しない" do
        create_daily_record(feed_stock: 301, feed_usage: 100)

        get root_path

        expect(response.body).not_to include("alert-bar")
      end

      it "日次記録がない場合はアラートバーを表示しない" do
        get root_path

        expect(response.body).not_to include("alert-bar")
      end

      it "feed_stockが0のときアラートバーを表示するが残日数は表示しない" do
        create_daily_record(feed_stock: 0, feed_usage: 100)

        get root_path

        expect(response.body).to include("alert-bar")
        expect(response.body).not_to include("日分程度")
      end

      it "feed_usageが0のときアラートバーを表示するが残日数は表示しない" do
        create_daily_record(feed_stock: 200, feed_usage: 0)

        get root_path

        expect(response.body).to include("alert-bar")
        expect(response.body).not_to include("日分程度")
      end
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
