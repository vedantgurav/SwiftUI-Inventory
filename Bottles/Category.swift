//
//  Bottle.swift
//  Bottles
//
//  Created by Vedant Gurav on 24/03/20.
//  Copyright © 2020 Vedant Gurav. All rights reserved.
//

import Foundation
import CoreData

public class Category:NSManagedObject, Identifiable {
    @NSManaged public var name:String?
    @NSManaged public var color:NSNumber?
}

extension Category {
    static func getCategories() -> NSFetchRequest<Category> {
        let request:NSFetchRequest<Category> = Category.fetchRequest() as! NSFetchRequest<Category>
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        return request
    }
}
