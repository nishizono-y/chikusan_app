import "@hotwired/turbo-rails"
import "controllers"

Turbo.StreamActions.visit = function() {
  Turbo.visit(this.getAttribute("target"))
}
