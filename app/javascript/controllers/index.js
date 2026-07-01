import { application } from "controllers/application"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
eagerLoadControllersFrom("controllers", application)

import FeedStockController from "controllers/feed_stock_controller"
application.register("feed-stock", FeedStockController)
