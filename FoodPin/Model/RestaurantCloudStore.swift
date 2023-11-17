//
//  RestaurantCloudStore.swift
//  FoodPin
//
//
//

import CloudKit
import SwiftUI

class RestaurantCloudStore: ObservableObject {
    
    @Published var restaurants: [CKRecord] = []
    
    func fetchRestaurants() async throws {
        // Fetch data using Convenience API
        let cloudContainer = CKContainer.default()
        let publicDatabase = cloudContainer.publicCloudDatabase
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Restaurant", predicate: predicate)
        query.sortDescriptors = [ NSSortDescriptor(key: "creationDate", ascending: false) ]
        
        let results = try await publicDatabase.records(matching: query)
        
        for record in results.matchResults {
            self.restaurants.append(try record.1.get())
        }
    }
    
    func fetchRestaurantsWithOperational(completion: @escaping () -> ()) {
        // Fetch data using Operational API
        let cloudContainer = CKContainer.default()
        let publicDatabase = cloudContainer.publicCloudDatabase
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Restaurant", predicate: predicate)
        query.sortDescriptors = [ NSSortDescriptor(key: "creationDate", ascending: false) ]
        
        // Create the query operation with the query
        let queryOperation = CKQueryOperation(query: query)
        queryOperation.desiredKeys = ["name", "image", "type", "location", "description"]
        queryOperation.queuePriority = .veryHigh
        queryOperation.resultsLimit = 50
        queryOperation.recordMatchedBlock = { (recordID, result) -> Void in
            
            if let _ = self.restaurants.first(where: { $0.recordID == recordID }) {
                return
            }
            
            if let restaurant = try? result.get() {
                DispatchQueue.main.async {
                    self.restaurants.append(restaurant)
                }
            }
        }
        
        queryOperation.queryResultBlock = { result -> Void in
            switch result {
            case .success(_): print("Successfully retrieve the data from iCloud.")
            case .failure(let error): print("Failed to get data from iCloud - \(error.localizedDescription)")
            }
            
            DispatchQueue.main.async {
                completion()
            }
        }
        
        // Execute the query
        publicDatabase.add(queryOperation)
    }
    
    func saveRecordToCloud(restaurant: Restaurant) {

        // Prepare the record to save
        let record = CKRecord(recordType: "Restaurant")
        record.setValue(restaurant.name, forKey: "name")
        record.setValue(restaurant.type, forKey: "type")
        record.setValue(restaurant.location, forKey: "location")
        record.setValue(restaurant.phone, forKey: "phone")
        record.setValue(restaurant.summary, forKey: "description")

        let imageData = restaurant.image as Data

        // Resize the image
        let originalImage = UIImage(data: imageData)!
        let scalingFactor = (originalImage.size.width > 1024) ? 1024 / originalImage.size.width : 1.0
        let scaledImage = UIImage(data: imageData, scale: scalingFactor)!

        // Write the image to local file for temporary use
        let imageFilePath = NSTemporaryDirectory() + restaurant.name
        let imageFileURL = URL(fileURLWithPath: imageFilePath)
        try? scaledImage.jpegData(compressionQuality: 0.8)?.write(to: imageFileURL)

        // Create image asset for upload
        let imageAsset = CKAsset(fileURL: imageFileURL)
        record.setValue(imageAsset, forKey: "image")

        // Get the Public iCloud Database
        let publicDatabase = CKContainer.default().publicCloudDatabase

        // Save the record to iCloud
        publicDatabase.save(record, completionHandler: { (record, error) -> Void  in

            if error != nil {
                print(error.debugDescription)
            }
            
            print("Successfully saved the record...")

            // Remove temp file
            try? FileManager.default.removeItem(at: imageFileURL)
        })
    }
}
