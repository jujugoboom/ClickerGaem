//
//  StoredAntimatterState+CoreDataProperties.swift
//  ClickerGaem
//
//  Created by Justin Covell on 9/25/24.
//
//

import Foundation
import CoreData


extension StoredAntimatterState {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<StoredAntimatterState> {
        return NSFetchRequest<StoredAntimatterState>(entityName: "StoredAntimatterState")
    }

    @NSManaged public var antimatter: NSObject?
    @NSManaged public var dimensionBoosts: Int64
    @NSManaged public var galaxies: Int64
    @NSManaged public var sacrificedDimensions: NSObject?
    @NSManaged public var tickSpeedUpgrades: NSObject?

}

extension StoredAntimatterState : Identifiable {

}
