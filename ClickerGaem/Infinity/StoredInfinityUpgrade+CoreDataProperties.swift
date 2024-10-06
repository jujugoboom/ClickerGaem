//
//  StoredInfinityUpgrade+CoreDataProperties.swift
//  ClickerGaem
//
//  Created by Justin Covell on 10/6/24.
//
//

import Foundation
import CoreData


extension StoredInfinityUpgrade {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<StoredInfinityUpgrade> {
        return NSFetchRequest<StoredInfinityUpgrade>(entityName: "StoredInfinityUpgrade")
    }

    @NSManaged public var id: String
    @NSManaged public var bought: Bool

}

extension StoredInfinityUpgrade : Identifiable {

}
