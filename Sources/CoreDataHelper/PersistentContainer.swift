//
//  File.swift
//  
//
//  Created by Lucas Pham on 2/8/20.
//

import Foundation
import CoreData

/// A CoredataStack with save, fetch, insert, delete method
///
/// You don't need to create a background context, just use a new id for new one
@available(OSX 10.12, *)
@available(iOS 10.0, *)
public class PersistentContainer: NSPersistentContainer {
    public let backgroundContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
    
    /// Collection of background Context with given id: `Int`
    public var backgroundContextCollection: [Int: NSManagedObjectContext] = [:]
    
    public override func loadPersistentStores(completionHandler block: @escaping (NSPersistentStoreDescription, Error?) -> Void) {
        super.loadPersistentStores { (storeDescription, err) in
            block(storeDescription, err)
            if err == nil {
                self.viewContext.automaticallyMergesChangesFromParent = true
                self.backgroundContext.parent = self.viewContext
                self.backgroundContext.automaticallyMergesChangesFromParent = true
            }
        }
    }
    
    /// Return a `NSManageObjectContext` with `privateQueueConcurrencyType` concurrency type
    /// - Parameter id: backgroundContext Id
    public func getBackgroundContext(withId id: Int) -> NSManagedObjectContext? {
        return self.backgroundContextCollection[id]
    }
    /// Remove a backgroundContext from this container
    /// - Parameter id: backgroundContext id
    public func removeBackgroundContext(id: Int) {
        self.backgroundContextCollection.removeValue(forKey: id)
    }
    
    /// Return `NSManageObjectContext` include `viewContext`, `backgroundContext` and other custom `backgroundContext`
    /// - Parameter workingMode: main or background
    internal func getContext(with workingMode: WorkingMode) -> NSManagedObjectContext {
        switch workingMode {
        case .main:
            return viewContext
        case .background:
            return backgroundContext
        case .backgroundWith(let id):
            guard let context = self.getBackgroundContext(withId: id) else {
                let newContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
                newContext.parent = viewContext
                newContext.automaticallyMergesChangesFromParent = true
                backgroundContextCollection[id] = newContext
                return newContext
            }
            return context
        }
    }
    
    public enum WorkingMode: Equatable {
        case main, background, backgroundWith(idContext: Int)
    }
}

@available(OSX 10.12, *)
@available(iOS 10.0, *)
extension PersistentContainer: CoreDataMethodExcutable {
    
    /// Save change with `workingMode`
    /// - Parameters:
    ///   - workingMode: main or background
    public func save(on workingMode: WorkingMode, complt: @escaping ((Error?) -> Void) = { _ in }) {
        self.save(self.getContext(with: workingMode), complt: complt)
    }
    public func saveAllContexts(complt: @escaping ((Error?) -> Void)) {
        backgroundContextCollection.forEach({
            do {
                try $1.save()
            } catch let err {
                complt(err)
            }
        })
        //Save parent of backgroundcontext
        do {
            try backgroundContext.save()
            try viewContext.save()
        } catch let err {
            complt(err)
        }
    }
    /// Fetch with `[Entity]` handler
    /// - Parameters:
    ///   - workingMode: main or background
    ///   - complt: handler with `Result<[Entity], Error>`
    public func fetch<Entity: NSManagedObject>(_ type: Entity.Type, on workingMode: WorkingMode, complt: @escaping (Result<[Entity], Error>) -> Void) {
        self.fetch(self.getContext(with: workingMode), complt: complt)
    }
    /// Delete a object with `whichInclude` condition
    /// - Parameters:
    ///   - workingMode: main or background
    ///   - whichInclude: condition
    ///   - complt: handler
    public func delete<Entity: NSManagedObject>(_ type: Entity.Type, on workingMode: WorkingMode, whichInclude: @escaping (Entity) -> Bool, complt: @escaping ((Error?) -> Void)) {
        self.delete(self.getContext(with: workingMode), whichInclude: whichInclude, complt: complt)
    }
    /// Insert on Object with configure it `setUpEntity`
    /// - Parameters:
    ///   - workingMode: main or background
    ///   - setUpEntity: set up an exist object
    ///   - complt: handler
    public func insert<Entity: NSManagedObject>(_ type: Entity.Type, on workingMode: WorkingMode, setUpEntity: @escaping (Entity) -> Void, complt: @escaping ((Error?) -> Void)) {
        self.insert(self.getContext(with: workingMode), initWith: setUpEntity, complt: complt)
    }
}
