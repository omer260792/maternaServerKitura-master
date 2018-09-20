//
//  Transaction.swift
//
//  Created by ido talmor on 08/03/2018.
//

import Foundation

public struct TransactionItem {
    
    /// ID
    public let docId: String
    public let status: String
    public let locationA: String
    public let locationAString: String
    public let locationAtime: String
    public let locationAdeliveryguy: String
    public let warehouse: String
    public let locationB: String
    public let locationBString: String
    public let locationBtime: String
    public let locationBdeliveryguy: String
    public let product: String
    public let expirationdate: String
    public let warehouseguy: String
    public let senderuid: String
    public let senderphonenumber: String
    public let sendername: String
    public let receiveruid: String
    public let receiverphonenumber: String
    public let receivername: String
    
    public init(docId: String,status: String, locationA: String, locationAString: String, locationAtime: String, locationAdeliveryguy: String, warehouse: String, locationB: String, locationBString: String, locationBtime: String, locationBdeliveryguy: String, product: String, expirationdate: String, warehouseguy: String, senderuid: String, senderphonenumber: String, sendername: String, receiveruid: String, receiverphonenumber: String, receivername: String) {
        
        self.docId = docId
        self.status = status
        self.locationA = locationA
        self.locationAString = locationAString
        self.locationAtime = locationAtime
        self.locationAdeliveryguy = locationAdeliveryguy
        self.warehouse = warehouse
        self.locationB = locationB
        self.locationBString = locationBString
        self.locationBtime = locationBtime
        self.locationBdeliveryguy = locationBdeliveryguy
        self.product = product
        self.expirationdate = expirationdate
        self.warehouseguy = warehouseguy
        self.senderuid = senderuid
        self.senderphonenumber = senderphonenumber
        self.sendername = sendername
        self.receiveruid = receiveruid
        self.receiverphonenumber = receiverphonenumber
        self.receivername = receivername
    }
}

extension TransactionItem: Equatable {
    public static func == (lhs: TransactionItem, rhs: TransactionItem) -> Bool {
        return lhs.docId == rhs.docId &&
        lhs.status == rhs.status &&
        lhs.locationA == rhs.locationA &&
        lhs.locationAString == rhs.locationAString &&
        lhs.locationAtime == rhs.locationAtime &&
        lhs.locationAdeliveryguy == rhs.locationAdeliveryguy &&
        lhs.warehouse == rhs.warehouse &&
        lhs.locationB == rhs.locationB &&
        lhs.locationBString == rhs.locationBString &&
        lhs.locationBtime == rhs.locationBtime &&
        lhs.locationBdeliveryguy == rhs.locationBdeliveryguy &&
        lhs.product == rhs.product &&
        lhs.expirationdate == rhs.expirationdate &&
        lhs.warehouseguy == rhs.warehouseguy &&
        lhs.senderuid == rhs.senderuid &&
        lhs.senderphonenumber == rhs.senderphonenumber &&
        lhs.sendername == rhs.sendername &&
        lhs.receiveruid == rhs.receiveruid &&
        lhs.receiverphonenumber == rhs.receiverphonenumber &&
        lhs.receivername == rhs.receivername
    }
}

extension TransactionItem: DictionaryConvertible {
    func toDict() -> JSONDictionary {
        var result = JSONDictionary()
        result["id"] = self.docId
        result["status"] = self.status
        result["locationA"] = self.locationA
        result["locationAString"] = self.locationAString
        result["locationAtime"] = self.locationAtime
        result["locationAdeliveryguy"] = self.locationAdeliveryguy
        result["warehouse"] = self.warehouse
        result["locationB"] = self.locationB
        result["locationBString"] = self.locationBString
        result["locationBtime"] = self.locationBtime
        result["locationBdeliveryguy"] = self.locationBdeliveryguy
        result["product"] = self.product
        result["expirationdate"] = self.expirationdate
        result["warehouseguy"] = self.warehouseguy
        result["senderuid"] = self.senderuid
        result["senderphonenumber"] = self.senderphonenumber
        result["sendername"] = self.sendername
        result["receiveruid"] = self.receiveruid
        result["receiverphonenumber"] = self.receiverphonenumber
        result["receivername"] = self.receivername
        
        return result
    }
}
