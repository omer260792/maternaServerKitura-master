import Foundation
import Kitura
import HeliumLogger
import LoggerAPI
import CloudFoundryEnv
import FoodTruckAPI

HeliumLogger.use()

let trucks: Materna

do {
  Log.info("Attempting init with CF environment")
  let service = try getConfig()
  Log.info("Init with Service")
  trucks = Materna(service: service)
} catch {
  Log.info("Could not retreive CF env: init with defaults")
  trucks = Materna()
}

let controller = MaternaController(backend: trucks)

do {
  let port = try CloudFoundryEnv.getAppEnv().port
  Log.verbose("Assigned port \(port)")
  
  Kitura.addHTTPServer(onPort: port, with: controller.router)
  Kitura.run()
} catch {
  Log.error("Server failed to start!")
}

