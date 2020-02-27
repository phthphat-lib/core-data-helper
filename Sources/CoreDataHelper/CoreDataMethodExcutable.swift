//
//  File.swift
//  
//
//  Created by Lucas Pham on 2/27/20.
//

import Foundation
import CoreData

// Protocol bring NSPersistentContainer save, fetch, insert, delete method
//
// Class inherit it must also inherit `NSPersistentContainter`
@available(iOS 10.0, *)
public protocol CoreDataMethodExcutable: NSPersistentContainer {
}
@available(iOS 10.0, *)
extension CoreDataMethodExcutable {
    ///Save custom context include its parent
    public func save(_ context: NSManagedObjectContext, complt: @escaping (Error?) -> Void) {
        if context.hasChanges {
            do {
                try context.save()
                try context.parent?.save()
                complt(nil)
            } catch {
                complt(error)
            }
        }
    }
    /// Fetch with custom context
    public func fetch<Entity: NSManagedObject>(_ context: NSManagedObjectContext, predicate: NSPredicate? = nil,complt: @escaping ((Result<[Entity], Error>) -> Void)) {
        let request = Entity.fetchRequest() as! NSFetchRequest<Entity>
        if let predicate = predicate {
            request.predicate = predicate
        }
        context.perform {
            do {
                let result = try context.fetch(request)
                DispatchQueue.main.async {
                    complt(.success(result))
                }
            } catch let err {
                print("Error on fetch: \(err.localizedDescription)")
                DispatchQueue.main.async {
                    complt(.failure(err))
                }
            }
        }
    }
    ///Insert object with custom context
    public func insert<Entity: NSManagedObject>(_ context: NSManagedObjectContext, initWith: @escaping (Entity) -> Void, complt: @escaping (Error?) -> Void) {
        context.perform {
            let object = Entity(entity: Entity.entity(), insertInto: context)
            initWith(object)
            context.insert(object)
        }
    }
    
    ///Delete object on `whichInclude` condition with custom context
    public func delete<Entity: NSManagedObject>(_ context: NSManagedObjectContext, whichInclude: @escaping (Entity) -> Bool, complt: @escaping (Error?) -> Void) {
        fetch(context) { (res: Result<[Entity], Error>) in
            switch res {
            case .success(let records):
                context.perform {
                    records.forEach { record in
                        if whichInclude(record) {
                            context.delete(record)
                        }
                    }
                    DispatchQueue.main.async {
                        complt(nil)
                    }
                }
            case .failure(let err):
                DispatchQueue.main.async {
                    complt(err)
                }
            }
        }
    }
}
