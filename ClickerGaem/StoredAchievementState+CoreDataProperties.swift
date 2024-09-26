//
//  StoredAchievementState+CoreDataProperties.swift
//  ClickerGaem
//
//  Created by Justin Covell on 9/25/24.
//
//

import Foundation
import CoreData


extension StoredAchievementState {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<StoredAchievementState> {
        return NSFetchRequest<StoredAchievementState>(entityName: "StoredAchievementState")
    }

    @NSManaged public var id: Int64
    @NSManaged public var unlocked: Bool

}

extension StoredAchievementState : Identifiable {

}
