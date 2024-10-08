//
//  StoredInfinityState+CoreDataProperties.swift
//  ClickerGaem
//
//  Created by Justin Covell on 10/6/24.
//
//

import Foundation
import CoreData


extension StoredInfinityState {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<StoredInfinityState> {
        return NSFetchRequest<StoredInfinityState>(entityName: "StoredInfinityState")
    }

    @NSManaged public var infinities: NSObject?
    @NSManaged public var infinitiesThisCrunch: NSObject?
    @NSManaged public var infinityBroken: Bool
    @NSManaged public var infinityPower: NSObject?
    @NSManaged public var infinityStartTime: Date?
    @NSManaged public var firstInfinity: Bool

}

extension StoredInfinityState : Identifiable {

}
