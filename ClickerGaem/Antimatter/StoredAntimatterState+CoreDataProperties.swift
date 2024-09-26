//
//  StoredAntimatterState+CoreDataProperties.swift
//  ClickerGaem
//
//  Created by Justin Covell on 9/24/24.
//
//

import Foundation
import CoreData


extension StoredAntimatterState {

    @nonobjc public class func createFetchRequest() -> NSFetchRequest<StoredAntimatterState> {
        return NSFetchRequest<StoredAntimatterState>(entityName: "StoredAntimatterState")
    }

    @NSManaged public var antimatter: NSObject?
    @NSManaged public var tickSpeedUpgrades: NSObject?
    @NSManaged public var galaxies: Int64
    @NSManaged public var dimensionBoosts: Int64
    @NSManaged public var sacrificedDimensions: NSObject?

}

extension StoredAntimatterState : Identifiable {

}
