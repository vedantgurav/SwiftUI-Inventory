//
//  Bottle+CoreDataProperties.swift
//  Bottles
//
//  Created by Vedant Gurav on 29/03/20.
//  Copyright © 2020 Vedant Gurav. All rights reserved.
//
//

import Foundation
import CoreData


extension Bottle {

//    @nonobjc public class func fetchRequest() -> NSFetchRequest<Bottle> {
//        return NSFetchRequest<Bottle>(entityName: "Bottle")
//    }

    @NSManaged public var capacity: Int16
    @NSManaged public var name: String?
    @NSManaged public var desc: String?
    @NSManaged public var open: Bool
    @NSManaged public var category: Category?
    @NSManaged public var location: Location?
    @NSManaged public var hidden: Bool

    public var wName: String {
        name ?? "Untitled Bottle"
    }
    
    public var wDesc: String {
        desc ?? ""
    }
    
}

extension Bottle {
    static func getAll() -> NSFetchRequest<Bottle> {
        let request:NSFetchRequest<Bottle> = Bottle.fetchRequest() as! NSFetchRequest<Bottle>
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true), NSSortDescriptor(key: "open", ascending: false), NSSortDescriptor(key: "desc", ascending: true), NSSortDescriptor(key: "location.name", ascending: true)]
        return request
    }

    static func getFiltered(filterKey:String, filterValue:String) -> NSFetchRequest<Bottle> {
        let request:NSFetchRequest<Bottle> = Bottle.fetchRequest() as! NSFetchRequest<Bottle>
        let sortKey = filterKey=="location" ? "category.name" : "location.name"
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true), NSSortDescriptor(key: "open", ascending: false), NSSortDescriptor(key: "desc", ascending: true), NSSortDescriptor(key: sortKey, ascending: true)]
        request.predicate = NSPredicate(format: "%K.name == %@",filterKey,filterValue)
        return request
    }

    static func getOpen(open:Bool) -> NSFetchRequest<Bottle> {
        let request:NSFetchRequest<Bottle> = Bottle.fetchRequest() as! NSFetchRequest<Bottle>
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true), NSSortDescriptor(key: "desc", ascending: true), NSSortDescriptor(key: "location.name", ascending: true)]
        request.predicate = NSPredicate(format: "open == %@", NSNumber(value: open))
        return request
    }
    
    static func getHidden() -> NSFetchRequest<Bottle> {
        let request:NSFetchRequest<Bottle> = Bottle.fetchRequest() as! NSFetchRequest<Bottle>
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true), NSSortDescriptor(key: "open", ascending: false), NSSortDescriptor(key: "desc", ascending: true), NSSortDescriptor(key: "location.name", ascending: true)]
        request.predicate = NSPredicate(format: "hidden == %@", NSNumber(true))
        return request
    }
}
