//
//  StoredGameState+CoreDataProperties.swift
//  ClickerGaem
//
//  Created by Justin Covell on 9/23/24.
//
//

import Foundation
import CoreData


extension StoredGameState {

    @nonobjc public class func createFetchRequest() -> NSFetchRequest<StoredGameState> {
        return NSFetchRequest<StoredGameState>(entityName: "StoredGameState")
    }

    @NSManaged public var antimatter: NSObject?
    @NSManaged public var ticksPerSecond: NSObject?
    @NSManaged public var updateInterval: Double
    @NSManaged public var dimensionStates: NSSet?

}

// MARK: Generated accessors for dimensionStates
extension StoredGameState {

    @objc(addDimensionStatesObject:)
    @NSManaged public func addToDimensionStates(_ value: StoredDimensionState)

    @objc(removeDimensionStatesObject:)
    @NSManaged public func removeFromDimensionStates(_ value: StoredDimensionState)

    @objc(addDimensionStates:)
    @NSManaged public func addToDimensionStates(_ values: NSSet)

    @objc(removeDimensionStates:)
    @NSManaged public func removeFromDimensionStates(_ values: NSSet)

}

extension StoredGameState : Identifiable {

}
