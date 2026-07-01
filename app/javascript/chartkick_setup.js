import Chartkick from "chartkick"
import { Chart } from "chart.js"
Chartkick.addAdapter(Chart)

document.addEventListener("turbo:load", (event) => {
  if (event.detail?.timing?.visitStart) {
    Chartkick.eachChart(chart => chart.redraw())
  }
})
