//
//  User+CoreDataProperties.swift
//  ExampleProject
//
//  Created by Lucas Pham on 2/27/20.
//  Copyright © 2020 phthphat. All rights reserved.
//
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var name: String?
    @NSManaged public var birthday: Date?

}
