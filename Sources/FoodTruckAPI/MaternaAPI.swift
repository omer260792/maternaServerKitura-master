public protocol MaternaAPI {
  
    func addUser(permission: String, phonenumber: String, Password: String, name: String, partneruid: String,mail: String,warehouse: String?,address:String?, completion: @escaping (UserItem?, Error?) -> Void)
    
   // func loginretrieveold(docId: String, completion: @escaping (UserItem?, Error?) -> Void)
    
    func loginUser(phonenumber : String, Password: String, completion: @escaping ([UserItem]?, Error?) -> Void)
    //transactions
    func addTransaction(status: String, locationA: String, locationAString: String, locationAtime: String, locationAdeliveryguy: String, warehouse: String, locationB: String, locationBString: String, locationBtime: String, locationBdeliveryguy: String, product: String, expirationdate: String, warehouseguy: String,senderuid: String, senderphonenumber: String, sendername: String, receiveruid: String, receiverphonenumber: String, receivername: String, completion: @escaping (TransactionItem?, Error?) -> Void)
    
    func updateTransaction(docId: String,status: String?, locationA: String?, locationAString: String?, locationAtime: String?, locationAdeliveryguy: String?, warehouse: String?, locationB: String?, locationBString: String?, locationBtime: String?, locationBdeliveryguy: String?, product: String?, expirationdate: String?, warehouseguy: String?,senderuid: String?, senderphonenumber: String?, sendername: String?, receiveruid: String?, receiverphonenumber: String?, receivername: String?, completion: @escaping (TransactionItem?, Error?) -> Void)
    
    //manager -
    func managerEye(warehouse : String, status: String, completion: @escaping ([TransactionItem]?, Error?) -> Void)
    
    //delivery
    func waitingForDelivery(completion: @escaping ([TransactionItem]?, Error?) -> Void)
    func locationAdeliveryguy(locationAdeliveryguy: String, completion: @escaping ([TransactionItem]?, Error?) -> Void)
    func locationBdeliveryguy(locationBdeliveryguy: String, completion: @escaping ([TransactionItem]?, Error?) -> Void)

    //sender
    func senderDone(senderuid : String, completion: @escaping ([TransactionItem]?, Error?) -> Void)
    func senderInProgress(senderuid : String, completion: @escaping ([TransactionItem]?, Error?) -> Void)
    
    //Receiver
    func receiverDone(receiveruid : String, completion: @escaping ([TransactionItem]?, Error?) -> Void)
    func receiverInProgress(receiveruid : String, completion: @escaping ([TransactionItem]?, Error?) -> Void)
    func donationList(warehouse : String, completion: @escaping ([TransactionItem]?, Error?) -> Void)

    
    



  // MARK: - Trucks
  // Get all Food Trucks
  func getAllTrucks(completion: @escaping ([MaternaItem]?, Error?) -> Void)
  
  // Get specific Food Truck
  func getTruck(docId: String, completion: @escaping (MaternaItem?, Error?) -> Void)
  
  // Add Food Truck
  func addTruck(name: String, foodType: String, avgCost: Float, latitude: Float, longitude: Float, completion: @escaping (MaternaItem?, Error?) -> Void)
  
  // Clear all Food Trucks
  func clearAll(completion: @escaping (Error?) -> Void)
  
  // Delete specific Food Truck
  func deleteTruck(docId: String, completion: @escaping (Error?) -> Void)
  
  // Update specific Food Truck
  func updateTruck(docId: String, name: String?, foodType: String?, avgCost: Float?, latitude: Float?, longitude: Float?, completion: @escaping (MaternaItem?, Error?) -> Void)
  
  // Get count of all Food Trucks
  func countTrucks(completion: @escaping (Int?, Error?) -> Void)
  
  // MARK: - REVIEWS
  // All Reviews for a specfic truck
  func getReviews(truckId: String, completion: @escaping ([ReviewItem]?, Error?) -> Void)
  
  // Specific review by id
  func getReview(docId: String, completion: @escaping (ReviewItem?, Error?) -> Void)
  
  // Add review for a specific truck
  func addReview(truckId: String, reviewTitle: String, reviewText: String, reviewStarRating: Int, completion: @escaping (ReviewItem?, Error?) -> Void)
  
  // Update a specific review
  func updateReview(docId: String, truckId: String?, reviewTitle: String?, reviewText: String?, starRating: Int?, completion: @escaping (ReviewItem?, Error?) -> Void)
  
  // Delete specific review
  func deleteReview(docId: String, completion: @escaping (Error?) -> Void)
  
  // Count of ALL reviews
  func countReviews(completion: @escaping (Int?, Error?) -> Void)
  
  // Count of reviews for a SPECIFIC truck
  func countReviews(truckId: String, completion: @escaping (Int?, Error?) -> Void)
  
  // Average star rating for a specific truck
  func averageRating(truckId: String, completion: @escaping (Int?, Error?) -> Void)
}











