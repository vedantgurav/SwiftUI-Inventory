//
//  Settings+CoreDataProperties.swift
//  Bottles
//
//  Created by Vedant Gurav on 25/04/20.
//  Copyright © 2020 Vedant Gurav. All rights reserved.
//
//

import Foundation
import CoreData


extension Settings {

//    @nonobjc public class func fetchRequest() -> NSFetchRequest<Settings> {
//        return NSFetchRequest<Settings>(entityName: "Settings")
//    }

    @NSManaged public var hiding: Bool
    @NSManaged public var searching: Bool
    @NSManaged public var showDesc: Bool
    @NSManaged public var separateGroup: Bool

}

extension Settings {
    static func getSettings() -> NSFetchRequest<Settings> {
        let request:NSFetchRequest<Settings> = Settings.fetchRequest() as! NSFetchRequest<Settings>
        request.sortDescriptors = []
        return request
    }
}
