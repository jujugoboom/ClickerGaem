//
//  StoredDimensionState+CoreDataProperties.swift
//  ClickerGaem
//
//  Created by Justin Covell on 9/25/24.
//
//

import Foundation
import CoreData


extension StoredDimensionState {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<StoredDimensionState> {
        return NSFetchRequest<StoredDimensionState>(entityName: "StoredDimensionState")
    }

    @NSManaged public var currCount: NSObject?
    @NSManaged public var purchaseCount: Int64
    @NSManaged public var tier: Int64
    @NSManaged public var unlocked: Bool

}

extension StoredDimensionState : Identifiable {

}
