//
//  Category+CoreDataProperties.swift
//  Bottles
//
//  Created by Vedant Gurav on 29/03/20.
//  Copyright © 2020 Vedant Gurav. All rights reserved.
//
//

import Foundation
import CoreData


extension Category {

//    @nonobjc public class func fetchRequest() -> NSFetchRequest<Category> {
//        return NSFetchRequest<Category>(entityName: "Category")
//    }

    @NSManaged public var name: String?
    @NSManaged public var color: String?
    @NSManaged public var bottle: NSSet?

    public var wName: String {
        name ?? "Untitled Category"
    }
    
    public var wColor: String {
        color ?? "#FFFFFFFF"
    }
    
    public var bottleArray: [Bottle] {
        let set = bottle as? Set<Bottle> ?? []
        return set.sorted {
            $0.wName < $1.wName
        }
    }
}

extension Category {
    static func getAll() -> NSFetchRequest<Category> {
        let request:NSFetchRequest<Category> = Category.fetchRequest() as! NSFetchRequest<Category>
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        return request
    }
}

// MARK: Generated accessors for bottle
//extension Category {
//
//    @objc(addBottleObject:)
//    @NSManaged public func addToBottle(_ value: Bottle)
//
//    @objc(removeBottleObject:)
//    @NSManaged public func removeFromBottle(_ value: Bottle)
//
//    @objc(addBottle:)
//    @NSManaged public func addToBottle(_ values: NSSet)
//
//    @objc(removeBottle:)
//    @NSManaged public func removeFromBottle(_ values: NSSet)
//
//}
