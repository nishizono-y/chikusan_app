require "net/http"
require "json"

class WeatherService
  BASE_URL = "https://api.openweathermap.org/data/2.5/weather"

  HEAT_STRESS_THRESHOLD = 35

  Result = Data.define(:temp, :humidity, :description, :icon_code, :heat_stress?)

  def self.fetch(lat:, lon:)
    new(lat:, lon:).fetch
  end

  def initialize(lat:, lon:)
    @lat = lat
    @lon = lon
  end

  def fetch
    response = Net::HTTP.get_response(uri)
    return nil unless response.is_a?(Net::HTTPSuccess)

    data = JSON.parse(response.body)
    main = data["main"]
    weather = data["weather"]&.first

    temp = main["temp"].round(1)
    Result.new(
      temp:,
      humidity: main["humidity"],
      description: weather&.dig("description") || "",
      icon_code: weather&.dig("icon") || "",
      heat_stress?: temp >= HEAT_STRESS_THRESHOLD
    )
  rescue StandardError
    nil
  end

  private

  def uri
    params = {
      lat: @lat,
      lon: @lon,
      appid: api_key,
      units: "metric",
      lang: "ja"
    }
    URI("#{BASE_URL}?#{URI.encode_www_form(params)}")
  end

  def api_key
    Rails.application.credentials.dig(:openweathermap, :api_key) ||
      ENV["OPENWEATHERMAP_API_KEY"]
  end
end
