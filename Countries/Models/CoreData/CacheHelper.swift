//
//  CacheHelper.swift
//  Countries
//
//  Created by AmirHossein Matloubi on 9/12/1401 AP.
//

import Foundation
import CoreData

final class CacheHelper {
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    
    let context = PersistanceContainer.shared.context
    
    
    func fetch(sortDescriptors: [NSSortDescriptor] = [], key: String, fetchLimit: Int? = nil) throws -> [Cache]? {
        let fetchRequest = Cache.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "key = %@", key)
        
        if let fetchLimit {
            fetchRequest.fetchLimit = fetchLimit
        }
        
        let fetchResult = try context.fetch(fetchRequest)
        return fetchResult
    }
    
    func fetch<T: Codable>(sortDescriptors: [NSSortDescriptor] = [], key: String) throws -> T? {
        let fetchResult = try fetch(sortDescriptors: sortDescriptors, key: key)?.first
        if let result = fetchResult?.value as? T, isPrimitive(value: result) {
            return result
        } else if let result = fetchResult?.value as? Data {
            return try decoder.decode(T.self, from: result)
        } else {
            return nil
        }
    }
    
    func fetch<T: Codable>(sortDescripors: [NSSortDescriptor] = [], key: String) throws -> [T] {
        let fetchResult = try fetch(sortDescriptors: sortDescripors, key: key, fetchLimit: nil)?.first
        guard let valueData = fetchResult?.value as? Data else { return [] }
        return try decoder.decode([T].self, from: valueData)
    }
    
    func addOrUpdate<T: Encodable>(value: T, key: String) throws {
        let isPrimitive = isPrimitive(value: value)
        
        if let context = try fetch(key: key), let cacheData = context.first {
            if isPrimitive {
                cacheData.value = value
            } else if let encodedValue = try? encoder.encode(value) {
                cacheData.value = encodedValue
            }
        } else {
            if isPrimitive {
                create(key: key, value: value)
            } else if let encodedValue = try? encoder.encode(value) {
                create(key: key, value: encodedValue)
            }
        }
        try save()
    }
    
    func delete(key: String) throws {
        let entity = try fetch(key: key)?.first
        
        if let entity = entity {
            context.delete(entity)
        }
        
        try save()
    }
    
    private func save() throws {
        if context.hasChanges {
            try context.save()
        }
    }
    
    private func create<T>(key: String, value: T) {
        let newEntity = Cache(context: context)
        newEntity.key = key
        newEntity.value = value
    }
    
    private func isPrimitive<T>(value: T) -> Bool {
        return value is String || value is Bool || value is Int || value is Float || value is Double
    }
    
}
