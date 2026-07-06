import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["lat", "lon", "error", "button"]

  fetch() {
    if (!("geolocation" in navigator)) {
      this.showError("このブラウザは位置情報の取得に対応していません。")
      return
    }

    this.hideError()
    this.buttonTarget.disabled = true

    navigator.geolocation.getCurrentPosition(
      (position) => {
        this.latTarget.value = position.coords.latitude.toFixed(6)
        this.lonTarget.value = position.coords.longitude.toFixed(6)
        this.buttonTarget.disabled = false
      },
      (error) => {
        this.showError(this.messageFor(error))
        this.buttonTarget.disabled = false
      },
      { enableHighAccuracy: true, timeout: 10000 }
    )
  }

  messageFor(error) {
    switch (error.code) {
      case error.PERMISSION_DENIED:
        return "位置情報の利用が許可されていません。ブラウザの設定を確認してください。"
      case error.POSITION_UNAVAILABLE:
        return "現在地を取得できませんでした。"
      case error.TIMEOUT:
        return "現在地の取得がタイムアウトしました。"
      default:
        return "現在地の取得に失敗しました。"
    }
  }

  showError(message) {
    this.errorTarget.textContent = message
    this.errorTarget.hidden = false
  }

  hideError() {
    this.errorTarget.hidden = true
  }
}
