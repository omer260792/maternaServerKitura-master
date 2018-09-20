

import Foundation
import Kitura
import LoggerAPI
import SwiftyJSON

public final class MaternaController {
  public let maternaapi: MaternaAPI
  public let router = Router()
  public let trucksPath = "api/v1/trucks"
  public let reviewsPath = "api/v1/reviews"
    public let usersPath = "api/v1/users"
    public let transactionsPath = "api/v1/transactions"

  
  public init(backend: MaternaAPI) {
    self.maternaapi = backend
    routeSetup()
  }
  
  public func routeSetup() {
    
    router.all("/*", middleware: BodyParser())
    
    // MARK :Materna
    //user handler
    router.post("\(usersPath)/signup", handler : addUser)
    router.post("\(usersPath)/login", handler : loginUser)
    
    //transactionhandler
    router.post("\(transactionsPath)/add", handler: addTransaction)
    router.post("\(transactionsPath)/update", handler: updateTransaction)

    
    //manager
    router.post("\(transactionsPath)/managereye", handler: managerEye)

    //delivery
    router.post("\(transactionsPath)/waitingfordelivery", handler: waitingForDelivery)
    router.post("\(transactionsPath)/locationadeliveryguy", handler: locationAdeliveryguy)
    router.post("\(transactionsPath)/locationbdeliveryguy", handler: locationBdeliveryguy)
    
    //sender
    router.post("\(transactionsPath)/senderdone", handler: senderDone)
    router.post("\(transactionsPath)/senderinprogress", handler: senderInProgress)
    
    //receiver
    
    router.post("\(transactionsPath)/receiverdone", handler: receiverDone)
    router.post("\(transactionsPath)/receiverinprogress", handler: receiverInProgress)
    router.post("\(transactionsPath)/donationlist", handler: donationList)

    // Food Truck Handling
    // All Trucks
    router.get(trucksPath, handler: getTrucks)
    // Add Truck
    router.post(trucksPath, handler: addTruck)
    // Truck Count
    router.get("\(trucksPath)/count", handler: getTruckCount)
    // Specific Truck
    router.get("\(trucksPath)/:id", handler: getTruckById)
    // Delete Truck
    router.delete("\(trucksPath)/:id", handler: deleteTruckById)
    // Update Truck (PUT)
    router.put("\(trucksPath)/:id", handler: updateTruckById)
    
    // Reviews Handling
    // Get all reviews for a specific truck
    router.get("\(trucksPath)/reviews/:id", handler: getAllReviewsForTruck)
    // Reviews Count
    router.get("\(reviewsPath)/count", handler: getReviewsCount)
    // Reviews count for specific truck
    router.get("\(reviewsPath)/count/:id", handler: getReviewCountForTruck)
    // Average star rating for truck
    router.get("\(reviewsPath)/rating/:id", handler: getAverageRatingForTruck)
    // Get specific review
    router.get("\(reviewsPath)/:id", handler: getReviewById)
    // Add review
    router.post("\(reviewsPath)/:id", handler: addReviewForTruck)
    // update review (PUT)
    router.put("\(reviewsPath)/:id", handler: updateReviewById)
    // Delete review
    router.delete("\(reviewsPath)/:id", handler: deleteReviewById)
  }
    

    
    
    private func loginUser(request: RouterRequest, response: RouterResponse, next: () -> Void) {
        guard let body = request.body else {
            response.status(.badRequest)
            Log.error("No body found in request")
            return
        }
        
        guard case let .json(json) = body else {
            response.status(.badRequest)
            Log.error("Invalid JSON data supplied")
            return
        }
        
        let phonenumber: String = json["phonenumber"].stringValue
        let Password: String = json["Password"].stringValue
        
        maternaapi.loginUser(phonenumber : phonenumber, Password: Password) { (userArr, err) in
            do {
                guard err == nil else {
                    try response.status(.badRequest).end()
                    Log.error(err.debugDescription)
                    return
                }
                if let userArr = userArr {
                    //convert user array to json
                    let result = JSON(userArr.toDict())
                    
                    //send json as a response
                    try response.status(.OK).send(json:result).end()
                } else {
                    Log.warning("Could not find a review by that ID")
                    response.status(.notFound)
                    return
                }
            } catch {
                Log.error("Communications Error")
            }
        }
    }
    
    
    private func addUser(request: RouterRequest, response: RouterResponse, next: () -> Void) {
        guard let body = request.body else {
            response.status(.badRequest)
            Log.error("No body found in request")
            return
        }
        
        guard case let .json(json) = body else {
            response.status(.badRequest)
            Log.error("Invalid JSON data supplied")
            return
        }
        
        let permission: String = json["permission"].stringValue
        let phonenumber: String = json["phonenumber"].stringValue
        let Password: String = json["Password"].stringValue
        let name: String = json["name"].stringValue
        let partneruid: String = json["partneruid"].stringValue
        let mail: String = json["mail"].stringValue
        let warehouse: String = json["warehouse"].stringValue
        let address: String = json["address"].stringValue


        guard name != "" else {
            response.status(.badRequest)
            Log.error("Necessary fields not supplied")
            return
        }

        maternaapi.addUser(permission: permission, phonenumber: phonenumber, Password: Password, name: name, partneruid: partneruid, mail: mail, warehouse: warehouse,address: address) { (user, err) in
            do {
                guard err == nil else {
                    try response.status(.badRequest).end()
                    Log.error(err.debugDescription)
                    return
                }
                
                guard let user = user else {
                    try response.status(.internalServerError).end()
                    Log.error("user not found")
                    return
                }
                
                let result = JSON(user.toDict())
                do {
                    try response.status(.OK).send(json: result).end()
                } catch {
                    Log.error("Error sending response")
                }
            } catch {
                Log.error("Communications error")
            }
        }
    }
    
    //transactions

    private func addTransaction(request: RouterRequest, response: RouterResponse, next: () -> Void) {
        guard let body = request.body else {
            response.status(.badRequest)
            Log.error("No body found in request")
            return
        }

        guard case let .json(json) = body else {
            response.status(.badRequest)
            Log.error("Invalid JSON data supplied")
            return
        }

        let status: String = json["status"].stringValue
        let locationA: String = json["locationA"].stringValue
        let locationAString: String = json["locationAString"].stringValue
        let locationAtime: String = json["locationAtime"].stringValue
        let locationAdeliveryguy: String = json["locationAdeliveryguy"].stringValue
        let warehouse: String = json["warehouse"].stringValue
        let locationB: String = json["locationB"].stringValue
        let locationBString: String = json["locationBString"].stringValue
        let locationBtime: String = json["locationBtime"].stringValue
        let locationBdeliveryguy: String = json["locationBdeliveryguy"].stringValue
        let product: String = json["product"].stringValue
        let expirationdate: String = json["expirationdate"].stringValue
        let warehouseguy: String = json["warehouseguy"].stringValue
        let senderuid: String = json["senderuid"].stringValue
        let senderphonenumber: String = json["senderphonenumber"].stringValue
        let sendername: String = json["sendername"].stringValue
        let receiveruid: String = json["receiveruid"].stringValue
        let receiverphonenumber: String = json["receiverphonenumber"].stringValue
        let receivername: String = json["receivername"].stringValue

        maternaapi.addTransaction(status: status, locationA: locationA, locationAString: locationAString, locationAtime: locationAtime, locationAdeliveryguy: locationAdeliveryguy, warehouse: warehouse, locationB: locationB, locationBString: locationBString, locationBtime: locationBtime, locationBdeliveryguy: locationBdeliveryguy, product: product, expirationdate: expirationdate, warehouseguy: warehouseguy, senderuid: senderuid, senderphonenumber: senderphonenumber, sendername: sendername, receiveruid: receiveruid, receiverphonenumber: receiverphonenumber, receivername: receivername) { (transaction, err) in
            do {
                                guard err == nil else {
                                    try response.status(.badRequest).end()
                                    Log.error(err.debugDescription)
                                    return
                                }

                                guard let transaction = transaction else {
                                    try response.status(.internalServerError).end()
                                    Log.error("transaction not found")
                                    return
                                }

                                let result = JSON(transaction.toDict())
                                Log.info("\(transaction.docId) added to transactions list")
                                do {
                                    try response.status(.OK).send(json: result).end()
                                } catch {
                                    Log.error("Error sending response")
                                }
                            } catch {
                                Log.error("Communications error")
                            }
                        }
        }
    
    
    private func updateTransaction(request: RouterRequest, response: RouterResponse, next: () -> Void) {

        
        guard let body = request.body else {
            response.status(.badRequest)
            Log.error("No Body found in request")
            return
        }
        
        guard case let .json(json) = body else {
            response.status(.badRequest)
            Log.error("Invalid JSON data supplied")
            return
        }

        let docId: String? = json["id"].stringValue == "" ? nil : json["id"].stringValue

        if docId == nil {return}
        
        let status: String? = json["status"].stringValue == "" ? nil : json["status"].stringValue
        let locationA: String? = json["locationA"].stringValue == "" ? nil : json["locationA"].stringValue
        let locationAString: String? = json["locationAString"].stringValue == "" ? nil : json["locationAString"].stringValue
        let locationAtime: String? = json["locationAtime"].stringValue == "" ? nil : json["locationAtime"].stringValue
        let locationAdeliveryguy: String? = json["locationAdeliveryguy"].stringValue == "" ? nil : json["locationAdeliveryguy"].stringValue
        let warehouse: String? = json["warehouse"].stringValue == "" ? nil : json["warehouse"].stringValue
        let locationB: String? = json["locationB"].stringValue == "" ? nil : json["locationB"].stringValue
        let locationBString: String? = json["locationBString"].stringValue == "" ? nil : json["locationBString"].stringValue
        let locationBtime: String? = json["locationBtime"].stringValue == "" ? nil : json["locationBtime"].stringValue
        let locationBdeliveryguy: String? = json["locationBdeliveryguy"].stringValue == "" ? nil : json["locationBdeliveryguy"].stringValue
        let product: String? = json["product"].stringValue == "" ? nil : json["product"].stringValue
        let expirationdate: String? = json["expirationdate"].stringValue == "" ? nil : json["expirationdate"].stringValue
        let warehouseguy: String? = json["warehouseguy"].stringValue == "" ? nil : json["warehouseguy"].stringValue
        let senderuid: String? = json["senderuid"].stringValue == "" ? nil : json["senderuid"].stringValue
        let senderphonenumber: String? = json["senderphonenumber"].stringValue == "" ? nil : json["senderphonenumber"].stringValue
        let sendername: String? = json["sendername"].stringValue == "" ? nil : json["sendername"].stringValue
        let receiveruid: String? = json["receiveruid"].stringValue == "" ? nil : json["receiveruid"].stringValue
        let receiverphonenumber: String? = json["receiverphonenumber"].stringValue == "" ? nil : json["receiverphonenumber"].stringValue
        let receivername: String? = json["receivername"].stringValue == "" ? nil : json["receivername"].stringValue


        maternaapi.updateTransaction(docId: docId!,status: status, locationA: locationA, locationAString: locationAString, locationAtime: locationAtime, locationAdeliveryguy: locationAdeliveryguy, warehouse: warehouse, locationB: locationB, locationBString: locationBString, locationBtime: locationBtime, locationBdeliveryguy: locationBdeliveryguy, product: product, expirationdate: expirationdate, warehouseguy: warehouseguy,senderuid: senderuid, senderphonenumber: senderphonenumber, sendername: sendername, receiveruid: receiveruid, receiverphonenumber: receiverphonenumber, receivername: receivername) { (updatedTransaction, err) in
            do {
                guard err == nil else {
                    try response.status(.badRequest).end()
                    Log.error(err.debugDescription)
                    return
                }
                if let updatedTransaction = updatedTransaction {
                    let result = JSON(updatedTransaction.toDict())
                    try response.status(.OK).send(json: result).end()
                } else {
                    Log.error("Invalid Transaction Returned")
                    try response.status(.badRequest).end()
                }
            } catch {
                Log.error("Communications Error")
            }
        }
    }

    //Manager Queries
    
    private func managerEye(request: RouterRequest, response: RouterResponse, next: () -> Void) {
        guard let body = request.body else {
            response.status(.badRequest)
            Log.error("No body found in request")
            return
        }
        
        guard case let .json(json) = body else {
            response.status(.badRequest)
            Log.error("Invalid JSON data supplied")
            return
        }
        
        let warehouse: String = json["warehouse"].stringValue
        let status: String = json["status"].stringValue
        
        maternaapi.managerEye(warehouse : warehouse, status: status) { (transactionArr, err) in
            do {
                guard err == nil else {
                    try response.status(.badRequest).end()
                    Log.error(err.debugDescription)
                    return
                }
                if let userArr = transactionArr {
                    //convert user array to json
                    let result = JSON(userArr.toDict())
                    
                    //send json as a response
                    try response.status(.OK).send(json:result).end()
                } else {
                    Log.warning("Could not find a review by that ID")
                    response.status(.notFound)
                    return
                }
            } catch {
                Log.error("Communications Error")
            }
        }
    }
    
    //Delivery Queries
    
    private func waitingForDelivery(request: RouterRequest, response: RouterResponse, next: () -> Void) {
        guard let body = request.body else {
            response.status(.badRequest)
            Log.error("No body found in request")
            return
        }
        
        guard case let .json(json) = body else {
            response.status(.badRequest)
            Log.error("Invalid JSON data supplied")
            return
        }

        maternaapi.waitingForDelivery{ (transactionArr, err) in
            do {
                guard err == nil else {
                    try response.status(.badRequest).end()
                    Log.error(err.debugDescription)
                    return
                }
                if let userArr = transactionArr {
                    //convert user array to json
                    let result = JSON(userArr.toDict())
                    
                    //send json as a response
                    try response.status(.OK).send(json:result).end()
                } else {
                    Log.warning("Could not find a review by that ID")
                    response.status(.notFound)
                    return
                }
            } catch {
                Log.error("Communications Error")
            }
        }
    }
    
    
    private func locationAdeliveryguy(request: RouterRequest, response: RouterResponse, next: () -> Void) {
        guard let body = request.body else {
            response.status(.badRequest)
            Log.error("No body found in request")
            return
        }
        
        guard case let .json(json) = body else {
            response.status(.badRequest)
            Log.error("Invalid JSON data supplied")
            return
        }
        
        let locationAdeliveryguy: String = json["locationAdeliveryguy"].stringValue
        
        maternaapi.locationAdeliveryguy(locationAdeliveryguy : locationAdeliveryguy) { (transactionArr, err) in
            do {
                guard err == nil else {
                    try response.status(.badRequest).end()
                    Log.error(err.debugDescription)
                    return
                }
                if let userArr = transactionArr {
                    //convert user array to json
                    let result = JSON(userArr.toDict())
                    
                    //send json as a response
                    try response.status(.OK).send(json:result).end()
                } else {
                    Log.warning("Could not find a review by that ID")
                    response.status(.notFound)
                    return
                }
            } catch {
                Log.error("Communications Error")
            }
        }
    }
    
    private func locationBdeliveryguy(request: RouterRequest, response: RouterResponse, next: () -> Void) {
        guard let body = request.body else {
            response.status(.badRequest)
            Log.error("No body found in request")
            return
        }
        
        guard case let .json(json) = body else {
            response.status(.badRequest)
            Log.error("Invalid JSON data supplied")
            return
        }
        
        let locationBdeliveryguy: String = json["locationBdeliveryguy"].stringValue
        
        maternaapi.locationBdeliveryguy(locationBdeliveryguy : locationBdeliveryguy) { (transactionArr, err) in
            do {
                guard err == nil else {
                    try response.status(.badRequest).end()
                    Log.error(err.debugDescription)
                    return
                }
                if let userArr = transactionArr {
                    //convert user array to json
                    let result = JSON(userArr.toDict())
                    
                    //send json as a response
                    try response.status(.OK).send(json:result).end()
                } else {
                    Log.warning("Could not find a review by that ID")
                    response.status(.notFound)
                    return
                }
            } catch {
                Log.error("Communications Error")
            }
        }
    }
    
    //Sender Queries
    
    private func senderDone(request: RouterRequest, response: RouterResponse, next: () -> Void) {
        guard let body = request.body else {
            response.status(.badRequest)
            Log.error("No body found in request")
            return
        }
        
        guard case let .json(json) = body else {
            response.status(.badRequest)
            Log.error("Invalid JSON data supplied")
            return
        }
        
        let senderuid: String = json["senderuid"].stringValue
        
        maternaapi.senderDone(senderuid : senderuid) { (transactionArr, err) in
            do {
                guard err == nil else {
                    try response.status(.badRequest).end()
                    Log.error(err.debugDescription)
                    return
                }
                if let userArr = transactionArr {
                    //convert user array to json
                    let result = JSON(userArr.toDict())
                    
                    //send json as a response
                    try response.status(.OK).send(json:result).end()
                } else {
                    Log.warning("Could not find a review by that ID")
                    response.status(.notFound)
                    return
                }
            } catch {
                Log.error("Communications Error")
            }
        }
    }
    
    private func senderInProgress(request: RouterRequest, response: RouterResponse, next: () -> Void) {
        guard let body = request.body else {
            response.status(.badRequest)
            Log.error("No body found in request")
            return
        }
        
        guard case let .json(json) = body else {
            response.status(.badRequest)
            Log.error("Invalid JSON data supplied")
            return
        }
        
        let senderuid: String = json["senderuid"].stringValue
        
        maternaapi.senderInProgress(senderuid : senderuid) { (transactionArr, err) in
            do {
                guard err == nil else {
                    try response.status(.badRequest).end()
                    Log.error(err.debugDescription)
                    return
                }
                if let userArr = transactionArr {
                    //convert user array to json
                    let result = JSON(userArr.toDict())
                    
                    //send json as a response
                    try response.status(.OK).send(json:result).end()
                } else {
                    Log.warning("Could not find a review by that ID")
                    response.status(.notFound)
                    return
                }
            } catch {
                Log.error("Communications Error")
            }
        }
    }
    
    //Receiver Queries
    
    private func receiverDone(request: RouterRequest, response: RouterResponse, next: () -> Void) {
        guard let body = request.body else {
            response.status(.badRequest)
            Log.error("No body found in request")
            return
        }
        
        guard case let .json(json) = body else {
            response.status(.badRequest)
            Log.error("Invalid JSON data supplied")
            return
        }
        
        let receiveruid: String = json["receiveruid"].stringValue
        
        maternaapi.receiverDone(receiveruid : receiveruid) { (transactionArr, err) in
            do {
                guard err == nil else {
                    try response.status(.badRequest).end()
                    Log.error(err.debugDescription)
                    return
                }
                if let userArr = transactionArr {
                    //convert user array to json
                    let result = JSON(userArr.toDict())
                    
                    //send json as a response
                    try response.status(.OK).send(json:result).end()
                } else {
                    Log.warning("Could not find a review by that ID")
                    response.status(.notFound)
                    return
                }
            } catch {
                Log.error("Communications Error")
            }
        }
    }
    
    
    private func receiverInProgress(request: RouterRequest, response: RouterResponse, next: () -> Void) {
        guard let body = request.body else {
            response.status(.badRequest)
            Log.error("No body found in request")
            return
        }
        
        guard case let .json(json) = body else {
            response.status(.badRequest)
            Log.error("Invalid JSON data supplied")
            return
        }
        
        let receiveruid: String = json["receiveruid"].stringValue
        
        maternaapi.receiverInProgress(receiveruid : receiveruid) { (transactionArr, err) in
            do {
                guard err == nil else {
                    try response.status(.badRequest).end()
                    Log.error(err.debugDescription)
                    return
                }
                if let userArr = transactionArr {
                    //convert user array to json
                    let result = JSON(userArr.toDict())
                    
                    //send json as a response
                    try response.status(.OK).send(json:result).end()
                } else {
                    Log.warning("Could not find a review by that ID")
                    response.status(.notFound)
                    return
                }
            } catch {
                Log.error("Communications Error")
            }
        }
    }
    
    private func donationList(request: RouterRequest, response: RouterResponse, next: () -> Void) {
        guard let body = request.body else {
            response.status(.badRequest)
            Log.error("No body found in request")
            return
        }
        
        guard case let .json(json) = body else {
            response.status(.badRequest)
            Log.error("Invalid JSON data supplied")
            return
        }
        
        let warehouse: String = json["warehouse"].stringValue
        
        maternaapi.donationList(warehouse : warehouse) { (transactionArr, err) in
            do {
                guard err == nil else {
                    try response.status(.badRequest).end()
                    Log.error(err.debugDescription)
                    return
                }
                if let userArr = transactionArr {
                    //convert user array to json
                    let result = JSON(userArr.toDict())
                    
                    //send json as a response
                    try response.status(.OK).send(json:result).end()
                } else {
                    Log.warning("Could not find a review by that ID")
                    response.status(.notFound)
                    return
                }
            } catch {
                Log.error("Communications Error")
            }
        }
    }
    
    
    
    
    //#######
  private func getTrucks(request: RouterRequest, response: RouterResponse, next: () -> Void) {
    maternaapi.getAllTrucks { (trucks, err) in
      do {
        guard err == nil else {
          try response.status(.badRequest).end()
          Log.error(err.debugDescription)
          return
        }
        guard let trucks = trucks else {
          try response.status(.internalServerError).end()
          Log.error("Failed to get trucks")
          return
        }
        let json = JSON(trucks.toDict())
        try response.status(.OK).send(json: json).end()
      } catch {
        Log.error("Communications error")
      }
    }
  }
  
  private func addTruck(request: RouterRequest, response: RouterResponse, next: () -> Void) {
    guard let body = request.body else {
      response.status(.badRequest)
      Log.error("No body found in request")
      return
    }
    
    guard case let .json(json) = body else {
      response.status(.badRequest)
      Log.error("Invalid JSON data supplied")
      return
    }
    
    let name: String = json["name"].stringValue
    let foodType: String = json["foodtype"].stringValue
    let avgCost: Float = json["avgcost"].floatValue
    let latitude: Float = json["latitude"].floatValue
    let longitude: Float = json["longitude"].floatValue
    
    guard name != "" else {
      response.status(.badRequest)
      Log.error("Necessary fields not supplied")
      return
    }
    
    maternaapi.addTruck(name: name, foodType: foodType, avgCost: avgCost, latitude: latitude, longitude: longitude) { (truck, err) in
      do {
        guard err == nil else {
          try response.status(.badRequest).end()
          Log.error(err.debugDescription)
          return
        }
        
        guard let truck = truck else {
          try response.status(.internalServerError).end()
          Log.error("Truck not found")
          return
        }
        
        let result = JSON(truck.toDict())
        Log.info("\(name) added to Vehicle list")
        do {
          try response.status(.OK).send(json: result).end()
        } catch {
          Log.error("Error sending response")
        }
      } catch {
        Log.error("Communications error")
      }
    }
  }
  
  private func getTruckById(request: RouterRequest, response: RouterResponse, next: () -> Void) {
    guard let docId = request.parameters["id"] else {
      response.status(.badRequest)
      Log.error("No ID supplied")
      return
    }
    
    maternaapi.getTruck(docId: docId) { (truck, err) in
      do {
        guard err == nil else {
          try response.status(.badRequest).end()
          Log.error(err.debugDescription)
          return
        }
        
        if let truck = truck {
          let result = JSON(truck.toDict())
          try response.status(.OK).send(json: result).end()
        } else {
          Log.warning("Could not find a truck by that ID")
          response.status(.notFound)
          return
        }
      } catch {
        Log.error("Communications Error")
      }
    }
  }
  
  private func deleteTruckById(request: RouterRequest, response: RouterResponse, next: () -> Void) {
    guard let docId = request.parameters["id"] else {
      response.status(.badRequest)
      Log.warning("ID not found in request")
      return
    }
    
    maternaapi.deleteTruck(docId: docId) { (err) in
      do {
        guard err == nil else {
          try response.status(.badRequest).end()
          Log.error(err.debugDescription)
          return
        }
        try response.status(.OK).end()
        Log.info("\(docId) successfully deleted")
      } catch {
        Log.error("Communication Error")
      }
    }
  }
  
  private func updateTruckById(request: RouterRequest, response: RouterResponse, next: () -> Void) {
    guard let docId = request.parameters["id"] else {
      response.status(.badRequest)
      Log.error("ID Not found in request")
      return
    }
    
    guard let body = request.body else {
      response.status(.badRequest)
      Log.error("No Body found in request")
      return
    }
    
    guard case let .json(json) = body else {
      response.status(.badRequest)
      Log.error("Invalid JSON data supplied")
      return
    }
    
    let name: String? = json["name"].stringValue == "" ? nil : json["name"].stringValue
    let foodType: String? = json["foodtype"].stringValue == "" ? nil : json["foodtype"].stringValue
    let avgCost: Float? = json["avgcost"].floatValue == 0 ? nil : json["avgcost"].floatValue
    let latitude: Float? = json["latitude"].floatValue == 0 ? nil : json["latitude"].floatValue
    let longitude: Float? = json["longitude"].floatValue == 0 ? nil : json["longitude"].floatValue
    
    maternaapi.updateTruck(docId: docId, name: name, foodType: foodType, avgCost: avgCost, latitude: latitude, longitude: longitude) { (updatedTruck, err) in
      do {
        guard err == nil else {
          try response.status(.badRequest).end()
          Log.error(err.debugDescription)
          return
        }
        if let updatedTruck = updatedTruck {
          let result = JSON(updatedTruck.toDict())
          try response.status(.OK).send(json: result).end()
        } else {
          Log.error("Invalid Truck Returned")
          try response.status(.badRequest).end()
        }
      } catch {
        Log.error("Communications Error")
      }
    }
  }
  
  private func getTruckCount(request: RouterRequest, response: RouterResponse, next: () -> Void) {
    maternaapi.countTrucks { (count, err) in
      do {
        guard err == nil else {
          try response.status(.badRequest).end()
          Log.error(err.debugDescription)
          return
        }
        guard let count = count else {
          try response.status(.internalServerError).end()
          Log.error("Failed to get count")
          return
        }
        let json = JSON(["count": count])
        try response.status(.OK).send(json: json).end()
      } catch {
        Log.error("Communications Error")
      }
    }
  }
  
  // Get all reviews for specific truck
  private func getAllReviewsForTruck(request: RouterRequest, response: RouterResponse, next: () -> Void) {
    guard let truckId = request.parameters["id"] else {
      response.status(.badRequest)
      Log.warning("ID not found in request")
      return
    }
    
    maternaapi.getReviews(truckId: truckId) { (reviews, err) in
      do {
        guard err == nil else {
          try response.status(.badRequest).end()
          Log.error(err.debugDescription)
          return
        }
        
        guard let reviews = reviews else {
          try response.status(.internalServerError).end()
          return
        }
        
        let json = JSON(reviews.toDict())
        try response.status(.OK).send(json: json).end()
      } catch {
        Log.error("Communications Error")
      }
    }
  }
  
  // Get specific review by id
  private func getReviewById(request: RouterRequest, response: RouterResponse, next: () -> Void) {
    guard let docId = request.parameters["id"] else {
      response.status(.badRequest)
      Log.error("No ID Supplied")
      return
    }
    
    maternaapi.getReview(docId: docId) { (review, err) in
      do {
        guard err == nil else {
          try response.status(.badRequest).end()
          Log.error(err.debugDescription)
          return
        }
        if let review = review {
          let result = JSON(review.toDict())
          try response.status(.OK).send(json: result).end()
        } else {
          Log.warning("Could not find a review by that ID")
          response.status(.notFound)
          return
        }
      } catch {
        Log.error("Communications Error")
      }
    }
  }
  
  // Add review for truck
  private func addReviewForTruck(request: RouterRequest, response: RouterResponse, next: () -> Void) {
    guard let truckId = request.parameters["id"] else {
      response.status(.badRequest)
      Log.warning("No TruckID found in request")
      return
    }
    
    guard let body = request.body else {
      response.status(.badRequest)
      Log.error("No body found in request")
      return
    }
    
    guard case let .json(json) = body else {
      response.status(.badRequest)
      Log.error("Invalid JSON data supplied")
      return
    }
    
    let title: String = json["reviewtitle"].stringValue
    let text: String = json["reviewtext"].stringValue
    let starRating: Int = json["starrating"].intValue
    
    guard title != "" else {
      response.status(.badRequest)
      Log.error("Necessary fields not supplied")
      return
    }
    
    maternaapi.addReview(truckId: truckId, reviewTitle: title, reviewText: text, reviewStarRating: starRating) { (review, err) in
      
      do {
        guard err == nil else {
          try response.status(.badRequest).end()
          Log.error(err.debugDescription)
          return
        }
        
        guard let review = review else {
          try response.status(.internalServerError).end()
          Log.error("Review Not Found")
          return
        }
        
        let result = JSON(review.toDict())
        Log.info("\(title) added to vehicle list")
        
        do {
          try response.status(.OK).send(json: result).end()
        } catch {
          Log.error("Error sending response")
        }
      } catch {
        Log.error("Communications Error")
      }
    }
  }
  
  // Update specific review by id
  private func updateReviewById(request: RouterRequest, response: RouterResponse, next: () -> Void) {
    guard let docId = request.parameters["id"] else {
      response.status(.badRequest)
      Log.error("ID Not found in request")
      return
    }
    
    guard let body = request.body else {
      response.status(.badRequest)
      Log.error("No body found in request")
      return
    }
    
    guard case let .json(json) = body else {
      response.status(.badRequest)
      Log.error("Invalid JSON data supplied")
      return
    }
    
    let truckId: String? = json["truckId"].stringValue == "" ? nil : json["truckId"].stringValue
    let reviewTitle: String? = json["reviewtitle"].stringValue == "" ? nil : json["reviewtitle"].stringValue
    let reviewText: String? = json["reviewtext"].stringValue == "" ? nil : json["reviewtext"].stringValue
    let starRating: Int? = json["starrating"].intValue == 0 ? nil : json["starrating"].intValue
    
    maternaapi.updateReview(docId: docId, truckId: truckId, reviewTitle: reviewTitle, reviewText: reviewText, starRating: starRating) { (updatedReview, err) in
      do {
        guard err == nil else {
          try response.status(.badRequest).end()
          Log.error(err.debugDescription)
          return
        }
        if let updatedReview = updatedReview {
          let result = JSON(updatedReview.toDict())
          try response.status(.OK).send(json: result).end()
        } else {
          Log.error("Invalid review returned")
          try response.status(.badRequest).end()
        }
      } catch {
        Log.error("Communications error")
      }
    }
  }
  
  // Delete review by id
  private func deleteReviewById(request: RouterRequest, response: RouterResponse, next: () -> Void) {
    guard let docId = request.parameters["id"] else {
      response.status(.badRequest)
      Log.warning("ID Not found in request")
      return
    }
    maternaapi.deleteReview(docId: docId) { (err) in
      do {
        guard err == nil else {
          try response.status(.badRequest).end()
          Log.error(err.debugDescription)
          return
        }
        try response.status(.OK).end()
        Log.info("\(docId) successfully deleted")
      } catch {
        Log.error("Communications Error")
      }
    }
  }
  
  // Get count of all reviews
  private func getReviewsCount(request: RouterRequest, response: RouterResponse, next: () -> Void) {
    maternaapi.countReviews { (count, err) in
      do {
        guard err == nil else {
          try response.status(.badRequest).end()
          Log.error(err.debugDescription)
          return
        }
        guard let count = count else {
          try response.status(.internalServerError).end()
          Log.error("Failed to get count")
          return
        }
        let json = JSON(["count": count])
        try response.status(.OK).send(json: json).end()
      } catch {
        Log.error("Commications Error")
      }
    }
  }
  
  // Get review count for a specific truck
  private func getReviewCountForTruck(request: RouterRequest, response: RouterResponse, next: () -> Void) {
    guard let truckId = request.parameters["id"] else {
      response.status(.badRequest)
      Log.warning("Truck ID Not found in request")
      return
    }
    
    maternaapi.countReviews(truckId: truckId) { (count, err) in
      do {
        guard err == nil else {
          try response.status(.badRequest).end()
          Log.error(err.debugDescription)
          return
        }
        
        guard let count = count else {
          try response.status(.internalServerError).end()
          Log.error("Failed to get count")
          return
        }
        
        let json = JSON(["count": count])
        try response.status(.OK).send(json: json).end()
      } catch {
        Log.error("Communications Error")
      }
    }
  }
  
  // Average star rating for a specific truck
  private func getAverageRatingForTruck(request: RouterRequest, response: RouterResponse, next: () -> Void) {
    guard let truckId = request.parameters["id"] else {
      response.status(.badRequest)
      Log.warning("Truck ID not found in request")
      return
    }
    
    maternaapi.averageRating(truckId: truckId) { (rating, err) in
      do {
        guard err == nil else {
          try response.status(.badRequest).end()
          Log.error(err.debugDescription)
          return
        }
        
        guard let rating = rating else {
          try response.status(.internalServerError).end()
          Log.error("Failed to get rating")
          return
        }
        
        let json = JSON(["avgrating": rating])
        try response.status(.OK).send(json: json).end()
      } catch {
        Log.error("Communications Error")
      }
    }
  }
}


//old

//    private func loginUser(request: RouterRequest, response: RouterResponse, next: () -> Void) {
//
//                guard let body = request.body else {
//                    response.status(.badRequest)
//                    Log.error("No body found in request")
//                    return
//                }
//
//                guard case let .json(json) = body else {
//                    response.status(.badRequest)
//                    Log.error("Invalid JSON data supplied")
//                    return
//                }
//                let inputphonenumber: String = json["phonenumber"].stringValue
//                let inputpassword: String = json["Password"].stringValue
//
////        trucks.loginretrieveold(docId: inputphonenumber) { (truck, err) in
////            do {
////                guard err == nil else {
////                    try response.status(.badRequest).end()
////                    Log.error(err.debugDescription)
////                    return
////                }
////
////                guard let truck = truck else {
////                    try response.status(.internalServerError).end()
////                    Log.error("Truck not found")
////                    return
////                }
////
////                let user = JSON(truck.toDict())
////                //let userpassword = user["password"].stringValue
////
////                if(truck.Password == inputpassword){
////                    do {
////                        try response.status(.OK).send(json: user).end()
////                    } catch {
////                        Log.error("Error sending response")
////                    }
////                }else{
////                    do {
////                        try response.status(.OK).send(json: []).end()
////                    } catch {
////                        Log.error("Error sending response")
////                    }}
////            } catch {
////                Log.error("Communications error")
////            }
////        }
//    }












