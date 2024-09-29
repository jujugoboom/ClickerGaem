//
//  StoredAutobuyerState+CoreDataProperties.swift
//  ClickerGaem
//
//  Created by Justin Covell on 9/29/24.
//
//

import Foundation
import CoreData


extension StoredAutobuyerState {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<StoredAutobuyerState> {
        return NSFetchRequest<StoredAutobuyerState>(entityName: "StoredAutobuyerState")
    }

    @NSManaged public var unlocked: Bool
    @NSManaged public var enabled: Bool
    @NSManaged public var purchased: Bool
    @NSManaged public var autobuyCount: Int64
    @NSManaged public var id: String?

}

extension StoredAutobuyerState : Identifiable {

}
