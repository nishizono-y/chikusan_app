require "rails_helper"

RSpec.describe WeatherService do
  let(:lat) { 31.8159 }
  let(:lon) { 130.3006 }
  let(:api_response) do
    {
      "main" => { "temp" => 28.5, "humidity" => 72 },
      "weather" => [ { "description" => "晴れ", "icon" => "01d" } ]
    }.to_json
  end

  before do
    allow(Rails.application.credentials).to receive(:dig).with(:openweathermap, :api_key).and_return("test_key")
  end

  describe ".fetch" do
    context "APIが正常に応答する場合" do
      before do
        stub_request(:get, /api.openweathermap.org/)
          .to_return(status: 200, body: api_response, headers: { "Content-Type" => "application/json" })
      end

      it "気温・湿度・天気を含む Result を返す" do
        result = described_class.fetch(lat:, lon:)
        expect(result.temp).to eq(28.5)
        expect(result.humidity).to eq(72)
        expect(result.description).to eq("晴れ")
        expect(result.icon_code).to eq("01d")
      end

      it "気温が35℃未満のとき heat_stress? が false" do
        result = described_class.fetch(lat:, lon:)
        expect(result.heat_stress?).to be false
      end
    end

    context "気温が35℃以上の場合" do
      let(:api_response) do
        {
          "main" => { "temp" => 37.2, "humidity" => 60 },
          "weather" => [ { "description" => "快晴", "icon" => "01d" } ]
        }.to_json
      end

      before do
        stub_request(:get, /api.openweathermap.org/)
          .to_return(status: 200, body: api_response, headers: { "Content-Type" => "application/json" })
      end

      it "heat_stress? が true" do
        result = described_class.fetch(lat:, lon:)
        expect(result.heat_stress?).to be true
      end
    end

    context "APIがエラーを返す場合" do
      before do
        stub_request(:get, /api.openweathermap.org/).to_return(status: 500)
      end

      it "nil を返す" do
        expect(described_class.fetch(lat:, lon:)).to be_nil
      end
    end

    context "ネットワークエラーの場合" do
      before do
        stub_request(:get, /api.openweathermap.org/).to_raise(SocketError)
      end

      it "nil を返す" do
        expect(described_class.fetch(lat:, lon:)).to be_nil
      end
    end

    context "APIキーが未設定の場合" do
      before do
        allow(Rails.application.credentials).to receive(:dig).with(:openweathermap, :api_key).and_return(nil)
        stub_const("ENV", ENV.to_h.except("OPENWEATHERMAP_API_KEY"))
      end

      it "リクエストを送らず nil を返す" do
        expect(described_class.fetch(lat:, lon:)).to be_nil
        expect(a_request(:get, /api.openweathermap.org/)).not_to have_been_made
      end
    end
  end
end
