
import Foundation




public struct MaternaItem {
  
  /// ID
  public let docId: String
  
  /// Name of the FoodTruck Business
  public let name: String
  
  /// Food Type
  public let foodType: String
  
  /// Average cost of the food served
  public let avgCost: Float
  
  /// Coordinate Latitude
  public let latitude: Float
  
  /// Coordinate Longitude
  public let longitude: Float
  
  public init(docId: String, name: String, foodType: String, avgCost: Float, latitude: Float, longitude: Float) {
    self.docId = docId
    self.name = name
    self.foodType = foodType
    self.avgCost = avgCost
    self.latitude = latitude
    self.longitude = longitude
  }
}

extension MaternaItem: Equatable {
  public static func == (lhs: MaternaItem, rhs: MaternaItem) -> Bool {
    return lhs.docId == rhs.docId &&
      lhs.name == rhs.name &&
      lhs.foodType == rhs.foodType &&
      lhs.avgCost == rhs.avgCost &&
      lhs.latitude == rhs.latitude &&
      lhs.longitude == rhs.longitude
  }
}

extension MaternaItem: DictionaryConvertible {
  func toDict() -> JSONDictionary {
    var result = JSONDictionary()
    result["id"] = self.docId
    result["name"] = self.name
    result["foodtype"] = self.foodType
    result["avgcost"] = self.avgCost
    result["latitude"] = self.latitude
    result["longitude"] = self.longitude
    
    return result
  }
}



