//
//  StoredGameState+CoreDataProperties.swift
//  ClickerGaem
//
//  Created by Justin Covell on 9/24/24.
//
//

import Foundation
import CoreData


extension StoredGameState {

    @nonobjc public class func createFetchRequest() -> NSFetchRequest<StoredGameState> {
        return NSFetchRequest<StoredGameState>(entityName: "StoredGameState")
    }

    @NSManaged public var updateInterval: Double

}

extension StoredGameState : Identifiable {

}
