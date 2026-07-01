import "@hotwired/turbo-rails"
import "controllers"
import Chartkick from "chartkick"
import "chart.js"

Chartkick.addAdapter(window.Chart)

document.addEventListener("turbo:load", (event) => {
  if (event.detail?.timing?.visitStart) {
    Chartkick.eachChart(chart => chart.redraw())
  }
})

Turbo.StreamActions.visit = function() {
  Turbo.visit(this.getAttribute("target"))
}
