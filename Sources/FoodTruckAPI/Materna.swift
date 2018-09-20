

import Foundation
import SwiftyJSON
import LoggerAPI
import CouchDB
import CloudFoundryEnv

#if os(Linux)
  typealias Valuetype = Any
#else
  typealias Valuetype = AnyObject
#endif

public enum APICollectionError: Error {
  case ParseError
  case AuthError
}

public class Materna: MaternaAPI {

    
    
  static let defaultDBHost = "localhost"
  static let defaultDBPort = UInt16(5984)
  static let defaultDBName = "maternaapi"
  static let defaultUsername = "jack"
  static let defaultPassword = "123456"
  
  let dbName = "maternaapi"
    let dbNameUsers = "users"
    let dbNameTransactions = "transactions"
    let designName = "maternadesign"
  let connectionProps: ConnectionProperties
  
  public init(database: String = Materna.defaultDBName, host: String = Materna.defaultDBHost, port: UInt16 = Materna.defaultDBPort, username: String? = Materna.defaultUsername, password: String? = Materna.defaultPassword) {
    
    let secured = (host == Materna.defaultDBHost) ? false : true
    connectionProps = ConnectionProperties(host: host, port: Int16(port), secured: secured, username: username, password: password)
    setupDb()
  }
  
  public convenience init (service: Service) {
    let host: String
    let username: String?
    let password: String?
    let port: UInt16
    let databaseName: String = "foodtruckapi"
    
    if let credentials = service.credentials, let tempHost = credentials["host"] as? String, let tempUsername = credentials["username"] as? String, let tempPassword = credentials["password"] as? String, let tempPort = credentials["port"] as? Int {
      
      host = tempHost
      username = tempUsername
      password = tempPassword
      port = UInt16(tempPort)
      Log.info("Using CF Service Credentials")
      
    } else {
      
      host = "localhost"
      username = "jack"
      password = "123456"
      port = UInt16(5984)
      Log.info("Using Service Development Credentials")
    }
    
    self.init(database: databaseName, host: host, port: port, username: username, password: password)
  }
  
  private func setupDb() {
    let couchClient = CouchDBClient(connectionProperties: self.connectionProps)
    couchClient.dbExists(dbName) { (exists, error) in
      if (exists) {
        Log.info("DB exists")
      } else {
        Log.error("DB does not exist \(error)")
        couchClient.createDB(self.dbName, callback: { (db, error) in
          if (db != nil) {
            Log.info("DB created!")
            self.setupDbDesign(db: db!)
          } else {
            Log.error("Unable to create DB \(self.dbName): Error \(error)")
          }
        })
      }
    }
  }
  
  private func setupDbDesign(db: Database) {
    let design: [String: Any] = [
      "_id": "_design/foodtruckdesign",
      "views": [
        "all_documents": [
          "map": "function(doc) { emit(doc._id, [doc._id, doc._rev]); }"
        ],
        "all_trucks": [
          "map": "function(doc) { if (doc.type == 'foodtruck') { emit(doc._id, [doc._id, doc.name, doc.foodtype, doc.avgcost, doc.latitude, doc.longitude]); }}"
        ],
        "total_trucks": [
          "map": "function(doc) { if (doc.type == 'foodtruck') { emit(doc._id, 1); }}",
          "reduce": "_count"
        ],
        "all_reviews": [
          "map": "function(doc) { if (doc.type == 'review') { emit(doc.truckid, [doc._id, doc.truckid, doc.reviewtitle, doc.reviewtext, doc.starrating]); }}"
        ],
        "total_reviews": [
          "map": "function(doc) { if (doc.type == 'review') { emit(doc.truckid, 1); }}",
          "reduce": "_count"
        ],
        "avg_rating": [
          "map": "function(doc) { if (doc.type == 'review') { emit(doc.truckid, doc.starrating); }}",
          "reduce": "_stats"
        ]
      ]
    ]
    
    db.createDesign(self.designName, document: JSON(design)) { (json, error) in
      if error != nil {
        Log.error("Failed to create design: \(error)")
      } else {
        Log.info("Design created: \(json)")
      }
    }
  }
  

//------------Materna
    //credentials
    //login
//    public func loginretrieveold(docId: String, completion: @escaping (UserItem?, Error?) -> Void){
//        let couchClient = CouchDBClient(connectionProperties: connectionProps)
//        let database = couchClient.database(dbNameUsers)
//
//        database.retrieve(docId) { (doc, err) in
//            guard let doc = doc,
//                let permission = doc["permission"].string,
//                let phonenumber = doc["phonenumber"].string,
//                let Password = doc["Password"].string,
//                let name = doc["name"].string,
//                let partneruid = doc["partneruid"].string,
//                let mail = doc["mail"].string else {
//                    completion(nil, err)
//                    return
//            }
//
//            let user = UserItem(docId: docId, permission: permission, phonenumber: phonenumber, Password: Password, name: name, partneruid: partneruid, mail: mail)
//            completion(user, nil)
//        }
//    }
    
    //samples javascript view code - couchDB
    
    //single parameters
    //    function(doc) {
    //    if (doc.Password){
    //    emit(doc.Password, [doc.phonenumber,doc.Password]);
    //    }
    //}
    //multiple parameters
    //    function(doc) {
    //    if (doc.phonenumber && doc.Password){
    //    emit([doc.phonenumber,doc.Password], [doc.phonenumber,doc.type]);
    //    }
    //    }
    
    
    //Add User
    public func addUser(permission: String, phonenumber: String, Password: String, name: String, partneruid: String, mail: String,warehouse: String?, address:String?, completion: @escaping (UserItem?, Error?) -> Void) {
        let json: [String:Any] = [
            "permission": permission,
            "phonenumber": phonenumber,
            "Password": Password,
            "name": name,
            "partneruid": partneruid,
            "mail": mail,
            "warehouse" : warehouse,
            "address" : address
            
        ]
        
        let couchClient = CouchDBClient(connectionProperties: connectionProps)
        let database = couchClient.database(dbNameUsers)
        
        database.create(JSON(json)) { (id, rev, doc, err) in
            if let id = id {
                let User = UserItem(docId: id, permission: permission, phonenumber: phonenumber, name: name, partneruid: partneruid, mail: mail, warehouse: warehouse,address: address)
                completion(User, nil)
            } else {
                completion(nil, err)
            }
        }
    }
    
    //login
    
    //login func
//    function(doc) {
//    if (doc.phonenumber && doc.Password){
//    emit([doc.phonenumber,doc.Password], [doc._id,doc.permission,doc.partneruid,doc.name,doc.mail,doc.phonenumber,doc.address]);
//    }
//    }
    public func loginUser(phonenumber : String, Password: String, completion: @escaping ([UserItem]?, Error?) -> Void) {
        let couchClient = CouchDBClient(connectionProperties: connectionProps)
        let database = couchClient.database(dbNameUsers)
        
        database.queryByView("login", ofDesign: "users", usingParameters: [.keys([[phonenumber,Password] as Valuetype]), .descending(true), .includeDocs(true)]) { (doc, err) in
            if let doc = doc, err == nil {
                do {
                    let userArr = try self.parseuser(doc)
                    completion(userArr, nil)
                } catch {
                    completion(nil, err)
                }
            }
            completion(nil, err)
        }
    }
    
    func parseuser(_ document: JSON) throws -> [UserItem] {
        guard let rows = document["rows"].array else {
            throw APICollectionError.ParseError
        }
        
        let userArr: [UserItem] = rows.flatMap {
            let doc = $0["value"]
            guard let id = doc[0].string,
                let permission = doc[1].string,
                let partneruid = doc[2].string,
                let name = doc[3].string,
                let mail = doc[4].string,
                let phonenumber = doc[5].string
                else {return nil}
            let warehouse = doc[6].string
            let address = doc[7].string

            return UserItem(docId: id, permission: permission, phonenumber: phonenumber, name: name, partneruid: partneruid, mail: mail, warehouse: warehouse,address: address)
        }
        return userArr
    }
    
    

    //Add Transaction
    public func addTransaction(status: String, locationA: String, locationAString: String, locationAtime: String, locationAdeliveryguy: String, warehouse: String, locationB: String, locationBString: String, locationBtime: String, locationBdeliveryguy: String, product: String, expirationdate: String, warehouseguy: String,senderuid: String, senderphonenumber: String, sendername: String, receiveruid: String, receiverphonenumber: String, receivername: String, completion: @escaping (TransactionItem?, Error?) -> Void) {
        
        let json: [String:Any] = [
            "status": status,
            "locationA": locationA,
            "locationAString": locationAString,
            "locationAtime": locationAtime,
            "locationAdeliveryguy": locationAdeliveryguy,
            "warehouse": warehouse,
            "locationB": locationB,
            "locationBString": locationBString,
            "locationBtime": locationBtime,
            "locationBdeliveryguy": locationBdeliveryguy,
            "product": product,
            "expirationdate": expirationdate,
            "warehouseguy": warehouseguy,
            "senderuid": senderuid,
            "senderphonenumber": senderphonenumber,
            "sendername": sendername,
            "receiveruid": receiveruid,
            "receiverphonenumber": receiverphonenumber,
            "receivername": receivername
        ]
        
        let couchClient = CouchDBClient(connectionProperties: connectionProps)
        let database = couchClient.database(dbNameTransactions)
        
        database.create(JSON(json)) { (id, rev, doc, err) in
            if let id = id {
                let transaction = TransactionItem(docId: id, status: status, locationA: locationA, locationAString: locationAString, locationAtime: locationAtime, locationAdeliveryguy: locationAdeliveryguy, warehouse: warehouse, locationB: locationB, locationBString: locationBString, locationBtime: locationBtime, locationBdeliveryguy: locationBdeliveryguy, product: product, expirationdate: expirationdate, warehouseguy: warehouseguy,senderuid: senderuid, senderphonenumber: senderphonenumber, sendername: sendername, receiveruid: receiveruid, receiverphonenumber: receiverphonenumber, receivername: receivername)
                completion(transaction, nil)
            } else {
                completion(nil, err)
            }
        }
    }
    
    
    public func updateTransaction(docId: String,status: String?, locationA: String?, locationAString: String?, locationAtime: String?, locationAdeliveryguy: String?, warehouse: String?, locationB: String?, locationBString: String?, locationBtime: String?, locationBdeliveryguy: String?, product: String?, expirationdate: String?, warehouseguy: String?,senderuid: String?, senderphonenumber: String?, sendername: String?, receiveruid: String?, receiverphonenumber: String?, receivername: String?, completion: @escaping (TransactionItem?, Error?) -> Void) {
        
        let couchClient = CouchDBClient(connectionProperties: connectionProps)
        let database = couchClient.database(dbNameTransactions)
        
        database.retrieve(docId) { (doc, err) in
            guard let doc = doc else {
                completion(nil, APICollectionError.AuthError)
                return
            }
            
            guard let rev = doc["_rev"].string else {
                completion(nil, APICollectionError.ParseError)
                return
            }
            
            let status = status ?? doc["status"].stringValue
            let locationA = locationA ?? doc["locationA"].stringValue
            let locationAString = locationAString ?? doc["locationAString"].stringValue
            let locationAtime = locationAtime ?? doc["locationAtime"].stringValue
            let locationAdeliveryguy = locationAdeliveryguy ?? doc["locationAdeliveryguy"].stringValue
            let warehouse = warehouse ?? doc["warehouse"].stringValue
            let locationB = locationB ?? doc["locationB"].stringValue
            let locationBString = locationBString ?? doc["locationBString"].stringValue
            let locationBtime = locationBtime ?? doc["locationBtime"].stringValue
            let locationBdeliveryguy = locationBdeliveryguy ?? doc["locationBdeliveryguy"].stringValue
            let product = product ?? doc["product"].stringValue
            let expirationdate = expirationdate ?? doc["expirationdate"].stringValue
            let warehouseguy = warehouseguy ?? doc["warehouseguy"].stringValue
            let senderuid = senderuid ?? doc["senderuid"].stringValue
            let senderphonenumber = senderphonenumber ?? doc["senderphonenumber"].stringValue
            let sendername = sendername ?? doc["sendername"].stringValue
            let receiveruid = receiveruid ?? doc["receiveruid"].stringValue
            let receiverphonenumber = receiverphonenumber ?? doc["receiverphonenumber"].stringValue
            let receivername = receivername ?? doc["receivername"].stringValue

            
            let json: [String: Any] = [
                "status": status,
                "locationA": locationA,
                "locationAString": locationAString,
                "locationAtime": locationAtime,
                "locationAdeliveryguy": locationAdeliveryguy,
                "warehouse": warehouse,
                "locationB": locationB,
                "locationBString": locationBString,
                "locationBtime": locationBtime,
                "locationBdeliveryguy": locationBdeliveryguy,
                "product": product,
                "expirationdate": expirationdate,
                "warehouseguy": warehouseguy,
                "senderuid": senderuid,
                "senderphonenumber": senderphonenumber,
                "sendername": sendername,
                "receiveruid": receiveruid,
                "receiverphonenumber": receiverphonenumber,
                "receivername": receivername
            ]
            
            database.update(docId, rev: rev, document: JSON(json), callback: { (rev, doc, err) in
                guard err == nil else {
                    completion(nil, err)
                    return
                }
                
                completion(TransactionItem(docId: docId, status: status, locationA: locationA, locationAString: locationAString, locationAtime: locationAtime, locationAdeliveryguy: locationAdeliveryguy, warehouse: warehouse, locationB: locationB, locationBString: locationBString, locationBtime: locationBtime, locationBdeliveryguy: locationBdeliveryguy, product: product, expirationdate: expirationdate, warehouseguy: warehouseguy,senderuid: senderuid, senderphonenumber: senderphonenumber, sendername: sendername, receiveruid: receiveruid, receiverphonenumber: receiverphonenumber, receivername: receivername), nil)
            })
        }
    }
    
    
    //query
    
    //manager
    //function (doc) {
//    emit([doc.warehouse,doc.status], [doc._id,doc.status,doc.locationA,doc.locationAString,doc.locationAtime,doc.locationAdeliveryguy,doc.warehouse,doc.locationB,doc.locationBString,doc.locationBtime,doc.locationBdeliveryguy,doc.product,doc.expirationdate,doc.warehouseguy,doc.senderuid,doc.senderphonenumber,doc.sendername,doc.receiveruid,doc.receiverphonenumber,doc.receivername]);
//}
    
    public func managerEye(warehouse : String, status: String, completion: @escaping ([TransactionItem]?, Error?) -> Void) {
        let couchClient = CouchDBClient(connectionProperties: connectionProps)
        let database = couchClient.database(dbNameTransactions)
        
        database.queryByView("managerEye", ofDesign: "Manager", usingParameters: [.keys([[warehouse,status] as Valuetype]), .descending(true), .includeDocs(true)]) { (doc, err) in
            if let doc = doc, err == nil {
                do {
                    let TransArr = try self.parsetransaction(doc)
                    completion(TransArr, nil)
                } catch {
                    completion(nil, err)
                }
            }
            completion(nil, err)
        }
    }
    
    //Delivery
    
//    function (doc) {
//    if(doc.status == "0" || doc.status == "3")
//    emit(doc._id,[doc._id,doc.status,doc.locationA,doc.locationAString,doc.locationAtime,doc.locationAdeliveryguy,doc.warehouse,doc.locationB,doc.locationBString,doc.locationBtime,doc.locationBdeliveryguy,doc.product,doc.expirationdate,doc.warehouseguy,doc.senderuid,doc.senderphonenumber,doc.sendername,doc.receiveruid,doc.receiverphonenumber,doc.receivername]);
//    }
    
    public func waitingForDelivery(completion: @escaping ([TransactionItem]?, Error?) -> Void) {
        let couchClient = CouchDBClient(connectionProperties: connectionProps)
        let database = couchClient.database(dbNameTransactions)
        
        database.queryByView("waitingForDelivery", ofDesign: "Delivery", usingParameters: [.descending(true), .includeDocs(true)]) { (doc, err) in
            if let doc = doc, err == nil {
                do {
                    let TransArr = try self.parsetransaction(doc)
                    completion(TransArr, nil)
                } catch {
                    completion(nil, err)
                }
            }
            completion(nil, err)
        }
    }
    
//    function (doc) {
//    if(doc.status == "1")
//    emit(doc.locationAdeliveryguy,[doc._id,doc.status,doc.locationA,doc.locationAString,doc.locationAtime,doc.locationAdeliveryguy,doc.warehouse,doc.locationB,doc.locationBString,doc.locationBtime,doc.locationBdeliveryguy,doc.product,doc.expirationdate,doc.warehouseguy,doc.senderuid,doc.senderphonenumber,doc.sendername,doc.receiveruid,doc.receiverphonenumber,doc.receivername]);
//    }
    
    public func locationAdeliveryguy(locationAdeliveryguy : String, completion: @escaping ([TransactionItem]?, Error?) -> Void) {
        let couchClient = CouchDBClient(connectionProperties: connectionProps)
        let database = couchClient.database(dbNameTransactions)
        
        database.queryByView("locationAdeliveryguy", ofDesign: "Delivery", usingParameters: [.keys([locationAdeliveryguy as Valuetype]), .descending(true), .includeDocs(true)]) { (doc, err) in
            if let doc = doc, err == nil {
                do {
                    let TransArr = try self.parsetransaction(doc)
                    completion(TransArr, nil)
                } catch {
                    completion(nil, err)
                }
            }
            completion(nil, err)
        }
    }
    
//    function (doc) {
//    if(doc.status == "4")
//    emit(doc.locationBdeliveryguy,[doc._id,doc.status,doc.locationA,doc.locationAString,doc.locationAtime,doc.locationAdeliveryguy,doc.warehouse,doc.locationB,doc.locationBString,doc.locationBtime,doc.locationBdeliveryguy,doc.product,doc.expirationdate,doc.warehouseguy,doc.senderuid,doc.senderphonenumber,doc.sendername,doc.receiveruid,doc.receiverphonenumber,doc.receivername]);
//    }

    public func locationBdeliveryguy(locationBdeliveryguy : String, completion: @escaping ([TransactionItem]?, Error?) -> Void) {
        let couchClient = CouchDBClient(connectionProperties: connectionProps)
        let database = couchClient.database(dbNameTransactions)
        
        database.queryByView("locationBdeliveryguy", ofDesign: "Delivery", usingParameters: [.keys([locationBdeliveryguy as Valuetype]), .descending(true), .includeDocs(true)]) { (doc, err) in
            if let doc = doc, err == nil {
                do {
                    let TransArr = try self.parsetransaction(doc)
                    completion(TransArr, nil)
                } catch {
                    completion(nil, err)
                }
            }
            completion(nil, err)
        }
    }
    
    //sender
    
//    function (doc) {
//    if(doc.status == "5")
//    emit(doc.senderuid, [doc._id,doc.status,doc.locationA,doc.locationAString,doc.locationAtime,doc.locationAdeliveryguy,doc.warehouse,doc.locationB,doc.locationBString,doc.locationBtime,doc.locationBdeliveryguy,doc.product,doc.expirationdate,doc.warehouseguy,doc.senderuid,doc.senderphonenumber,doc.sendername,doc.receiveruid,doc.receiverphonenumber,doc.receivername]);
//    }
    
    public func senderDone(senderuid : String, completion: @escaping ([TransactionItem]?, Error?) -> Void) {
        let couchClient = CouchDBClient(connectionProperties: connectionProps)
        let database = couchClient.database(dbNameTransactions)
        
        database.queryByView("done", ofDesign: "Sender", usingParameters: [.keys([senderuid as Valuetype]), .descending(true), .includeDocs(true)]) { (doc, err) in
            if let doc = doc, err == nil {
                do {
                    let TransArr = try self.parsetransaction(doc)
                    completion(TransArr, nil)
                } catch {
                    completion(nil, err)
                }
            }
            completion(nil, err)
        }
    }
    
//    function (doc) {
//    if(doc.status != "5")
//    emit(doc.senderuid, [doc._id,doc.status,doc.locationA,doc.locationAString,doc.locationAtime,doc.locationAdeliveryguy,doc.warehouse,doc.locationB,doc.locationBString,doc.locationBtime,doc.locationBdeliveryguy,doc.product,doc.expirationdate,doc.warehouseguy,doc.senderuid,doc.senderphonenumber,doc.sendername,doc.receiveruid,doc.receiverphonenumber,doc.receivername]);
//    }
    
    public func senderInProgress(senderuid : String, completion: @escaping ([TransactionItem]?, Error?) -> Void) {
        let couchClient = CouchDBClient(connectionProperties: connectionProps)
        let database = couchClient.database(dbNameTransactions)
        
        database.queryByView("inProgress", ofDesign: "Sender", usingParameters: [.keys([senderuid as Valuetype]), .descending(true), .includeDocs(true)]) { (doc, err) in
            if let doc = doc, err == nil {
                do {
                    let TransArr = try self.parsetransaction(doc)
                    completion(TransArr, nil)
                } catch {
                    completion(nil, err)
                }
            }
            completion(nil, err)
        }
    }
    
//    function (doc) {
//    if(doc.status == "5")
//    emit(doc.receiveruid, [doc._id,doc.status,doc.locationA,doc.locationAString,doc.locationAtime,doc.locationAdeliveryguy,doc.warehouse,doc.locationB,doc.locationBString,doc.locationBtime,doc.locationBdeliveryguy,doc.product,doc.expirationdate,doc.warehouseguy,doc.senderuid,doc.senderphonenumber,doc.sendername,doc.receiveruid,doc.receiverphonenumber,doc.receivername]);
//    }
    
    public func receiverDone(receiveruid : String, completion: @escaping ([TransactionItem]?, Error?) -> Void) {
        let couchClient = CouchDBClient(connectionProperties: connectionProps)
        let database = couchClient.database(dbNameTransactions)
        
        database.queryByView("done", ofDesign: "Receiver", usingParameters: [.keys([receiveruid as Valuetype]), .descending(true), .includeDocs(true)]) { (doc, err) in
            if let doc = doc, err == nil {
                do {
                    let TransArr = try self.parsetransaction(doc)
                    completion(TransArr, nil)
                } catch {
                    completion(nil, err)
                }
            }
            completion(nil, err)
        }
    }
    
//    function (doc) {
//    if(doc.status != "5")
//    emit(doc.receiveruid, [doc._id,doc.status,doc.locationA,doc.locationAString,doc.locationAtime,doc.locationAdeliveryguy,doc.warehouse,doc.locationB,doc.locationBString,doc.locationBtime,doc.locationBdeliveryguy,doc.product,doc.expirationdate,doc.warehouseguy,doc.senderuid,doc.senderphonenumber,doc.sendername,doc.receiveruid,doc.receiverphonenumber,doc.receivername]);
//    }
//
    
    public func receiverInProgress(receiveruid : String, completion: @escaping ([TransactionItem]?, Error?) -> Void) {
        let couchClient = CouchDBClient(connectionProperties: connectionProps)
        let database = couchClient.database(dbNameTransactions)
        
        database.queryByView("inProgress", ofDesign: "Receiver", usingParameters: [.keys([receiveruid as Valuetype]), .descending(true), .includeDocs(true)]) { (doc, err) in
            if let doc = doc, err == nil {
                do {
                    let TransArr = try self.parsetransaction(doc)
                    completion(TransArr, nil)
                } catch {
                    completion(nil, err)
                }
            }
            completion(nil, err)
        }
    }
    
//    function (doc) {
//    if(doc.status == "2")
//    emit(doc.warehouse, [doc._id,doc.status,doc.locationA,doc.locationAString,doc.locationAtime,doc.locationAdeliveryguy,doc.warehouse,doc.locationB,doc.locationBString,doc.locationBtime,doc.locationBdeliveryguy,doc.product,doc.expirationdate,doc.warehouseguy,doc.senderuid,doc.senderphonenumber,doc.sendername,doc.receiveruid,doc.receiverphonenumber,doc.receivername]);
//    }
    
    public func donationList(warehouse : String, completion: @escaping ([TransactionItem]?, Error?) -> Void) {
        let couchClient = CouchDBClient(connectionProperties: connectionProps)
        let database = couchClient.database(dbNameTransactions)
        
        database.queryByView("donationList", ofDesign: "Receiver", usingParameters: [.keys([warehouse as Valuetype]), .descending(true), .includeDocs(true)]) { (doc, err) in
            if let doc = doc, err == nil {
                do {
                    let TransArr = try self.parsetransaction(doc)
                    completion(TransArr, nil)
                } catch {
                    completion(nil, err)
                }
            }
            completion(nil, err)
        }
    }
    
    
    
    func parsetransaction(_ document: JSON) throws -> [TransactionItem] {
        guard let rows = document["rows"].array else {
            throw APICollectionError.ParseError
        }
        
        let transactionArr: [TransactionItem] = rows.flatMap {
            let doc = $0["value"]
            guard let docId = doc[0].string,
                let status = doc[1].string,
                let locationA = doc[2].string,
                let locationAString = doc[3].string,
                let locationAtime = doc[4].string,
                let locationAdeliveryguy = doc[5].string,
                let warehouse = doc[6].string,
                let locationB = doc[7].string,
                let locationBString = doc[8].string,
                let locationBtime = doc[9].string,
                let locationBdeliveryguy = doc[10].string,
                let product = doc[11].string,
                let expirationdate = doc[12].string,
                let warehouseguy = doc[13].string,
                let senderuid = doc[14].string,
                let senderphonenumber = doc[15].string,
                let sendername = doc[16].string,
                let receiveruid = doc[17].string,
                let receiverphonenumber = doc[18].string,
                let receivername = doc[19].string
                else {return nil}
            return TransactionItem(docId: docId, status: status, locationA: locationA, locationAString: locationAString, locationAtime: locationAtime, locationAdeliveryguy: locationAdeliveryguy, warehouse: warehouse, locationB: locationB, locationBString: locationBString, locationBtime: locationBtime, locationBdeliveryguy: locationBdeliveryguy, product: product, expirationdate: expirationdate, warehouseguy: warehouseguy, senderuid: senderuid, senderphonenumber: senderphonenumber, sendername: sendername, receiveruid: receiveruid, receiverphonenumber: receiverphonenumber, receivername: receivername)
        }
        return transactionArr
    }
    

    
    
    
    
/////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    
    
    
    public func getAllTrucks(completion: @escaping ([MaternaItem]?, Error?) -> Void) {
        let couchClient = CouchDBClient(connectionProperties: connectionProps)
        let database = couchClient.database(dbName)
        
        database.queryByView("all_trucks", ofDesign: designName, usingParameters: [.descending(true), .includeDocs(true)]) { doc, err in
            if let doc = doc, err == nil {
                do {
                    let trucks = try self.parseTrucks(doc)
                    completion(trucks, nil)
                } catch {
                    completion(nil, err)
                }
            } else {
                completion(nil, err)
            }
        }
    }
    
    func parseTrucks(_ document: JSON) throws -> [MaternaItem] {
        guard let rows = document["rows"].array else {
            throw APICollectionError.ParseError
        }
        
        let trucks: [MaternaItem] = rows.flatMap {
            let doc = $0["value"]
            guard let id = doc[0].string,
                let name = doc[1].string,
                let foodType = doc[2].string,
                let avgCost = doc[3].float,
                let latitude = doc[4].float,
                let longitude = doc[5].float else {
                    return nil
            }
            return MaternaItem(docId: id, name: name, foodType: foodType, avgCost: avgCost, latitude: latitude, longitude: longitude)
        }
        return trucks
    }
    
    // Get specific Food Truck
    public func getTruck(docId: String, completion: @escaping (MaternaItem?, Error?) -> Void){
        let couchClient = CouchDBClient(connectionProperties: connectionProps)
        let database = couchClient.database(dbName)
        
        database.retrieve(docId) { (doc, err) in
            guard let doc = doc,
                let docId = doc["_id"].string,
                let name = doc["name"].string,
                let foodType = doc["foodtype"].string,
                let avgCost = doc["avgcost"].float,
                let latitude = doc["latitude"].float,
                let longitude = doc["longitude"].float else {
                    completion(nil, err)
                    return
            }
            
            let truckItem = MaternaItem(docId: docId, name: name, foodType: foodType, avgCost: avgCost, latitude: latitude, longitude: longitude)
            completion(truckItem, nil)
        }
    }
    
    
  // Add Food Truck
  public func addTruck(name: String, foodType: String, avgCost: Float, latitude: Float, longitude: Float, completion: @escaping (MaternaItem?, Error?) -> Void) {
    let json: [String:Any] = [
      "type": "foodtruck",
      "name": name,
      "foodtype": foodType,
      "avgcost": avgCost,
      "latitude": latitude,
      "longitude": longitude
    ]
    
    let couchClient = CouchDBClient(connectionProperties: connectionProps)
    let database = couchClient.database(dbName)
    
    database.create(JSON(json)) { (id, rev, doc, err) in
      if let id = id {
        let truckItem = MaternaItem(docId: id, name: name, foodType: foodType, avgCost: avgCost, latitude: latitude, longitude: longitude)
        completion(truckItem, nil)
      } else {
        completion(nil, err)
      }
    }
  }
  
  // Clear all Food Trucks
  public func clearAll(completion: @escaping (Error?) -> Void) {
    let couchClient = CouchDBClient(connectionProperties: connectionProps)
    let database = couchClient.database(dbName)
    
    database.queryByView("all_documents", ofDesign: "foodtruckdesign", usingParameters: [.descending(true), .includeDocs(true)]) { (doc, err) in
      guard let doc = doc else {
        completion(err)
        return
      }
      
      guard let idAndRev = try? self.getIdAndRev(doc) else {
        completion(err)
        return
      }
      
      if idAndRev.count == 0 {
        completion(nil)
      } else {
        for i in 0...idAndRev.count - 1 {
          let truck = idAndRev[i]
          
          database.delete(truck.0, rev: truck.1, callback: { (err) in
            guard err == nil else {
              completion(err)
              return
            }
            completion(nil)
          })
        }
      }
    }
  }
  
  func getIdAndRev(_ document: JSON) throws -> [(String, String)] {
    guard let rows = document["rows"].array else {
      throw APICollectionError.ParseError
    }
    
    return rows.flatMap {
      let doc = $0["doc"]
      let id = doc["_id"].stringValue
      let rev = doc["_rev"].stringValue
      return (id, rev)
    }
  }
  
  // Delete specific Food Truck
  public func deleteTruck(docId: String, completion: @escaping (Error?) -> Void) {
    let couchClient = CouchDBClient(connectionProperties: connectionProps)
    let database = couchClient.database(dbName)
    
    database.retrieve(docId) { (doc, err) in
      guard let doc = doc, err == nil else {
        completion(err)
        return
      }
      
      // Fetch all reviews for the truck
      self.getReviews(truckId: docId, completion: { (reviews, err) in
        guard let reviews = reviews, err == nil else {
          completion(err)
          return
        }
        // Step through each review in the array
        for review in reviews {
          // Then delete this particular review
          self.deleteReview(docId: review.docId, completion: { (err) in
            guard err == nil else {
              completion(nil)
              return
            }
          })
        }
      })
      
      let rev = doc["_rev"].stringValue
      database.delete(docId, rev: rev) { (err) in
        if err != nil {
          completion(err)
        } else {
          completion(nil)
        }
      }
    }
  }
  
  // Update specific Food Truck
  public func updateTruck(docId: String, name: String?, foodType: String?, avgCost: Float?, latitude: Float?, longitude: Float?, completion: @escaping (MaternaItem?, Error?) -> Void) {
    let couchClient = CouchDBClient(connectionProperties: connectionProps)
    let database = couchClient.database(dbName)
    
    database.retrieve(docId) { (doc, err) in
      guard let doc = doc else {
        completion(nil, APICollectionError.AuthError)
        return
      }
      
      guard let rev = doc["_rev"].string else {
        completion(nil, APICollectionError.ParseError)
        return
      }
      
      let type = "foodtruck"
      let name = name ?? doc["name"].stringValue
      let foodType = foodType ?? doc["foodtype"].stringValue
      let avgCost = avgCost ?? doc["avgcost"].floatValue
      let latitude = latitude ?? doc["latitude"].floatValue
      let longitude = longitude ?? doc["longitude"].floatValue
      
      let json: [String: Any] = [
        "type": type,
        "name": name,
        "foodtype": foodType,
        "avgcost": avgCost,
        "latitude": latitude,
        "longitude": longitude
      ]
      
      database.update(docId, rev: rev, document: JSON(json), callback: { (rev, doc, err) in
        guard err == nil else {
          completion(nil, err)
          return
        }
        
        completion(MaternaItem(docId: docId, name: name, foodType: foodType, avgCost: avgCost, latitude: latitude, longitude: longitude), nil)
      })
    }
  }
  
  // Count of all Food Trucks
  public func countTrucks(completion: @escaping (Int?, Error?) -> Void) {
    let couchClient = CouchDBClient(connectionProperties: connectionProps)
    let database = couchClient.database(dbName)
    
    database.queryByView("total_trucks", ofDesign: "foodtruckdesign", usingParameters: []) { (doc, err) in
      if let doc = doc, err == nil {
        if let count = doc["rows"][0]["value"].int {
          completion(count, nil)
        } else {
          completion(0, nil)
        }
      } else {
        completion(nil, err)
      }
    }
  }
  
  // All Reviews for a specfic truck
  public func getReviews(truckId: String, completion: @escaping ([ReviewItem]?, Error?) -> Void) {
    let couchClient = CouchDBClient(connectionProperties: connectionProps)
    let database = couchClient.database(dbName)
    
    database.queryByView("all_reviews", ofDesign: designName, usingParameters: [.keys([truckId as Valuetype]), .descending(true), .includeDocs(true)]) { (doc, err) in
      if let doc = doc, err == nil {
        do {
          let reviews = try self.parseReviews(doc)
          completion(reviews, nil)
        } catch {
          completion(nil, err)
        }
      }
      completion(nil, err)
    }
  }
  
  func parseReviews(_ document: JSON) throws -> [ReviewItem] {
    guard let rows = document["rows"].array else {
      throw APICollectionError.ParseError
    }
    
    let reviews: [ReviewItem] = rows.flatMap {
      let doc = $0["value"]
      guard let id = doc[0].string,
        let truckId = doc[1].string,
        let reviewTitle = doc[2].string,
        let reviewText = doc[3].string,
        let starRating = doc[4].int else {
          return nil
      }
      return ReviewItem(docId: id, truckId: truckId, title: reviewTitle, reviewText: reviewText, starRating: starRating)
    }
    return reviews
  }
  
  // Specific review by id
  public func getReview(docId: String, completion: @escaping (ReviewItem?, Error?) -> Void) {
    let couchClient = CouchDBClient(connectionProperties: connectionProps)
    let database = couchClient.database(dbName)
    database.retrieve(docId) { (doc, err) in
      guard let doc = doc else {
        completion(nil, err)
        return
      }
      
      guard let docId = doc["_id"].string,
        let truckId = doc["truckid"].string,
        let reviewTitle = doc["reviewtitle"].string,
        let reviewText = doc["reviewtext"].string,
        let starRating = doc["starrating"].int else {
          completion(nil, err)
          return
      }
      
      let reviewItem = ReviewItem(docId: docId, truckId: truckId, title: reviewTitle, reviewText: reviewText, starRating: starRating)
      completion(reviewItem, nil)
    }
  }
  
  // Add review for a specific truck
  public func addReview(truckId: String, reviewTitle: String, reviewText: String, reviewStarRating: Int, completion: @escaping (ReviewItem?, Error?) -> Void) {
    
    let json: [String: Any] = [
      "type": "review",
      "truckid": truckId,
      "reviewtitle": reviewTitle,
      "reviewtext": reviewText,
      "starrating": reviewStarRating
    ]
    
    let couchClient = CouchDBClient(connectionProperties: connectionProps)
    let database = couchClient.database(dbName)
    
    database.create(JSON(json)) { (id, rev, doc, err) in
      if let id = id {
        let reviewItem = ReviewItem(docId: id, truckId: truckId, title: reviewTitle, reviewText: reviewText, starRating: reviewStarRating)
        completion(reviewItem, nil)
      } else {
        completion(nil, err)
      }
    }
  }
  
  // Update a specific review
  public func updateReview(docId: String, truckId: String?, reviewTitle: String?, reviewText: String?, starRating: Int?, completion: @escaping (ReviewItem?, Error?) -> Void) {
    let couchClient = CouchDBClient(connectionProperties: connectionProps)
    let database = couchClient.database(dbName)
    
    database.retrieve(docId) { (doc, err) in
      guard let doc = doc else {
        completion(nil, APICollectionError.AuthError)
        return
      }
      
      guard let rev = doc["_rev"].string else {
        completion(nil, APICollectionError.ParseError)
        return
      }
      
      let type = "review"
      let truckId = truckId ?? doc["truckid"].stringValue
      let reviewTitle = reviewTitle ?? doc["reviewtitle"].stringValue
      let reviewText = reviewText ?? doc["reviewtext"].stringValue
      let starRating = starRating ?? doc["starrating"].intValue
      
      let json: [String: Any] = [
        "type": type,
        "truckid": truckId,
        "reviewtitle": reviewTitle,
        "reviewtext": reviewText,
        "starrating": starRating
      ]
      
      database.update(docId, rev: rev, document: JSON(json), callback: { (rev, doc, err) in
        guard err == nil else {
          completion(nil, err)
          return
        }
        
        completion(ReviewItem(docId: docId, truckId: truckId, title: reviewTitle, reviewText: reviewText, starRating: starRating), nil)
      })
    }
  }
  
  // Delete specific review
  public func deleteReview(docId: String, completion: @escaping (Error?) -> Void) {
    let couchClient = CouchDBClient(connectionProperties: connectionProps)
    let database = couchClient.database(dbName)
    
    database.retrieve(docId) { (doc, err) in
      guard let doc = doc, err == nil else {
        completion(err)
        return
      }
      
      let rev = doc["_rev"].stringValue
      database.delete(docId, rev: rev, callback: { (err) in
        if err != nil {
          completion(err)
        } else {
          completion(nil)
        }
      })
    }
  }
  
  // Count of ALL reviews
  public func countReviews(completion: @escaping (Int?, Error?) -> Void) {
    let couchClient = CouchDBClient(connectionProperties: connectionProps)
    let database = couchClient.database(dbName)
    
    database.queryByView("total_reviews", ofDesign: designName, usingParameters: []) { (doc, err) in
      if let doc = doc, err == nil {
        if let count = doc["rows"][0]["value"].int {
          completion(count, nil)
        } else {
          completion(0, nil)
        }
      } else {
        completion(nil, err)
      }
    }
  }
  
  // Count of reviews for a SPECIFIC truck
  public func countReviews(truckId: String, completion: @escaping (Int?, Error?) -> Void) {
    let couchClient = CouchDBClient(connectionProperties: connectionProps)
    let database = couchClient.database(dbName)
    
    database.queryByView("total_reviews", ofDesign: designName, usingParameters: [.keys([truckId as Valuetype])]) { (doc, err) in
      if let doc = doc, err == nil {
        if let count = doc["rows"][0]["value"].int {
          completion(count, nil)
        } else {
          completion(0, nil)
        }
      } else {
        completion(nil, err)
      }
    }
  }
  
  // Average star rating for a specific truck
  public func averageRating(truckId: String, completion: @escaping (Int?, Error?) -> Void) {
    let couchClient = CouchDBClient(connectionProperties: connectionProps)
    let database = couchClient.database(dbName)
    
    database.queryByView("avg_rating", ofDesign: designName, usingParameters: [.keys([truckId as Valuetype])]) { (doc, err) in
      if let doc = doc, err == nil {
        if let sum = doc["rows"][0]["value"]["sum"].float, let count = doc["rows"][0]["value"]["count"].float {
          let avg = Int(round(sum / count))
          completion(avg, nil)
        } else {
          completion(1, nil)
        }
      } else {
        completion(nil, err)
      }
    }
  }
}


















