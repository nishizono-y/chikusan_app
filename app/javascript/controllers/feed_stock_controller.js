import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["usage", "stock"]
  static values = { prevStock: Number }

  connect() {
    const poll = setInterval(() => {
      if (this.usageTarget.value !== "") {
        this.calculate()
        clearInterval(poll)
      }
    }, 100)
    setTimeout(() => clearInterval(poll), 3000)
  }

  calculate() {
    const usage = parseInt(this.usageTarget.value, 10)
    if (!isNaN(usage) && this.hasPrevStockValue && this.prevStockValue > 0) {
      this.stockTarget.value = Math.max(this.prevStockValue - usage, 0)
    }
  }
}
