
import Foundation

typealias JSONDictionary = [String: Any]

protocol DictionaryConvertible {
    func toDict() -> JSONDictionary
}

public struct UserItem {
    
    public let docId: String
    public let permission: String
    public let phonenumber: String
    public let name: String
    public let partneruid: String
    public let mail: String
    public let warehouse: String?
    public let address: String?

    public init(docId: String, permission: String, phonenumber: String, name: String, partneruid: String, mail: String, warehouse: String?,address:String?) {
        self.docId = docId
        self.permission = permission
        self.phonenumber = phonenumber
        self.name = name
        self.partneruid = partneruid
        self.mail = mail
        self.warehouse = warehouse
        self.address = address

    }
}

extension UserItem: Equatable {
    public static func == (lhs: UserItem, rhs: UserItem) -> Bool {
        return lhs.docId == rhs.docId &&
            lhs.permission == rhs.permission &&
            lhs.phonenumber == rhs.phonenumber &&
            lhs.name == rhs.name &&
            lhs.partneruid == rhs.partneruid &&
            lhs.mail == rhs.mail &&
        lhs.warehouse == rhs.warehouse &&
            lhs.address == rhs.address
    }
}

extension UserItem: DictionaryConvertible {
    func toDict() -> JSONDictionary {
        var result = JSONDictionary()
        result["id"] = self.docId
        result["permission"] = self.permission
        result["phonenumber"] = self.phonenumber
        result["name"] = self.name
        result["partneruid"] = self.partneruid
        result["mail"] = self.mail
        result["warehouse"] = self.warehouse
        result["address"] = self.address
        return result
    }
}

extension Array where Element: DictionaryConvertible {
    func toDict() -> [JSONDictionary] {
        return self.map { $0.toDict() }
    }
}
