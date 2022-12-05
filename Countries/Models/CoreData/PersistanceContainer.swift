//
//  PersistanceContainer.swift
//  Countries
//
//  Created by AmirHossein Matloubi on 9/12/1401 AP.
//

import Foundation
import CoreData

class PersistanceContainer {
    public static let shared = PersistanceContainer()
    private static let modelName = "CacheDataModel"
    
    private let container: NSPersistentContainer
    
    private let managedObjectModel: NSManagedObjectModel = {
        
        guard let url = Bundle.main.url(forResource: modelName, withExtension: "momd") else {
            fatalError("Failed to locate momd file for xcdatamodeld")
        }
        
        guard let model = NSManagedObjectModel(contentsOf: url) else {
            fatalError("Failed to load momd file for xcdatamodeld")
        }
        
        return model
    }()
    
    var context: NSManagedObjectContext {
        container.viewContext
    }
    
    init() {
        container = NSPersistentContainer(name: PersistanceContainer.modelName, managedObjectModel: managedObjectModel)
        container.loadPersistentStores { storeDescription, error in
            if let error {
                print("Unresolved error:", error)
            }
            
            self.container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        }
    }
}

