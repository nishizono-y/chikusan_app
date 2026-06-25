// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import Chartkick from "chartkick"
import { Chart } from "chart.js"
Chartkick.addAdapter(Chart)

document.addEventListener("turbo:load", () => Chartkick.eachChart(chart => chart.redraw()))

Turbo.StreamActions.visit = function() {
  Turbo.visit(this.getAttribute("target"))
}
