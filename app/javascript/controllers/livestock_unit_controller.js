import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["select", "unit"]

  connect() {
    this.updateUnit()
  }

  updateUnit() {
    const option = this.selectTarget.selectedOptions[0]
    const unit = option?.dataset.unit
    const text = unit ? `（${unit}）` : ""
    this.unitTargets.forEach((target) => { target.textContent = text })
  }
}
