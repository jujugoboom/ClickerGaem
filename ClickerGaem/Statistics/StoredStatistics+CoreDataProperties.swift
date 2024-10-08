//
//  StoredStatistics+CoreDataProperties.swift
//  ClickerGaem
//
//  Created by Justin Covell on 10/6/24.
//
//

import Foundation
import CoreData


extension StoredStatistics {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<StoredStatistics> {
        return NSFetchRequest<StoredStatistics>(entityName: "StoredStatistics")
    }

    @NSManaged public var totalAntimatter: NSObject?
    @NSManaged public var totalInfinities: NSObject?
    @NSManaged public var startDate: Date?
    @NSManaged public var bestAMs: NSObject?
    @NSManaged public var bestInfinitiesS: NSObject?
    @NSManaged public var fastestInfinity: Double

}

extension StoredStatistics : Identifiable {

}
