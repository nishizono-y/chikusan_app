require "rails_helper"

RSpec.describe "/", type: :request do
  before do
    stub_request(:get, /api.openweathermap.org/).to_return(status: 500)
  end

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
      expect(response.body).not_to include("死亡 99頭")  # 直近記録セクションに前月データが出ないこと
      expect(response.body).to include(">73<")           # サマリー統計が当月のみ集計すること（バグ時は172になり失敗）
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
        create_daily_record(feed_stock: Setting.feed_stock_threshold, feed_usage: 100)

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
        create_daily_record(feed_stock: Setting.feed_stock_threshold + 1, feed_usage: 100)

        get root_path

        expect(response.body).not_to include("alert-bar")
      end

      it "日次記録がない場合はアラートバーを表示しない" do
        get root_path

        expect(response.body).not_to include("alert-bar")
      end

      it "feed_stockがfeed_usage未満（1日分未満）のとき残り1日分程度と表示する" do
        create_daily_record(feed_stock: 10, feed_usage: 50)

        get root_path

        expect(response.body).to include("残り1日分程度")
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

      it "当月記録がない場合はアラートバーを表示しない" do
        create_daily_record(date: Date.current.prev_month, feed_stock: 100, feed_usage: 50)

        get root_path

        expect(response.body).not_to include("alert-bar")
      end

      it "アラートに発注記録ページへのリンクを表示する" do
        create_daily_record(feed_stock: Setting.feed_stock_threshold, feed_usage: 100)

        get root_path

        expect(response.body).to include("発注する")
      end

      it "直近記録の日付以降に発注記録があるとき「発注済み」を表示しアラートを消す" do
        create_daily_record(feed_stock: Setting.feed_stock_threshold, feed_usage: 100)
        FeedOrder.create!(ordered_on: Date.current, quantity: 300, supplier: "JA薩摩川内")

        get root_path

        expect(response.body).to include("飼料は発注済みです")
        expect(response.body).not_to include("飼料残量が少なくなっています")
      end

      it "直近記録の日付より前の発注記録では「発注済み」にならない" do
        create_daily_record(feed_stock: Setting.feed_stock_threshold, feed_usage: 100)
        FeedOrder.create!(ordered_on: Date.current - 10, quantity: 300, supplier: "JA薩摩川内")

        get root_path

        expect(response.body).to include("飼料残量が少なくなっています")
        expect(response.body).not_to include("飼料は発注済みです")
      end
    end

    context "天気情報のキャッシュ" do
      around do |example|
        original_cache = Rails.cache
        Rails.cache = ActiveSupport::Cache::MemoryStore.new
        example.run
        Rails.cache = original_cache
      end

      before do
        allow(Rails.application.credentials).to receive(:dig).with(:openweathermap, :api_key).and_return("test_key")
      end

      it "取得に成功した場合、2回目以降のリクエストでは外部APIを呼び直さない" do
        stub_request(:get, /api.openweathermap.org/).to_return(
          status: 200,
          body: { main: { temp: 28.0, humidity: 60 }, weather: [ { description: "晴れ", icon: "01d" } ] }.to_json,
          headers: { "Content-Type" => "application/json" }
        )

        get root_path
        get root_path

        expect(a_request(:get, /api.openweathermap.org/)).to have_been_made.once
      end

      it "取得に失敗した場合も直後の再リクエストでは外部APIを呼び直さない（短時間のnilキャッシュ）" do
        stub_request(:get, /api.openweathermap.org/).to_return(status: 500)

        get root_path
        get root_path

        expect(a_request(:get, /api.openweathermap.org/)).to have_been_made.once
      end

      it "失敗結果のキャッシュ有効期限は成功結果より短い" do
        stub_request(:get, /api.openweathermap.org/).to_return(status: 500)

        get root_path

        cache_key = "weather:#{HomeController::FARM_LAT}:#{HomeController::FARM_LON}"
        entry = Rails.cache.send(:read_entry, Rails.cache.send(:normalize_key, cache_key, nil))
        expect(entry.expires_at).to be_within(5).of(1.minute.from_now.to_f)
      end
    end
  end

  private

  def create_daily_record(attrs = {})
    DailyRecord.create!(
      { date: Date.current, head_count: 20, death_count: 0, feed_usage: 100, feed_stock: 500, vaccine: "なし" }.merge(attrs)
    )
  end

  def create_shipment(attrs = {})
    Shipment.create!(
      { shipped_at: Date.current, count: 1, avg_weight: 110.0, destination: "テスト先" }.merge(attrs)
    )
  end
end
