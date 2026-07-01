import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["usage", "stock"]
  static values = { prevStock: Number }

  connect() {
    if (!this.hasUsageTarget) return
    this.calculate()
  }

  calculate() {
    const usage = parseInt(this.usageTarget.value, 10)
    if (!isNaN(usage) && this.hasPrevStockValue) {
      this.stockTarget.value = Math.max(this.prevStockValue - usage, 0)
    }
  }
}
