//
//  DimensionState.swift
//  ClickerGaem
//
//  Created by Justin Covell on 9/16/24.
//

import Foundation
import CoreData

/// Main dimension state. 
@Observable
final class DimensionState: Saveable {
    var storedState: StoredDimensionState?
    let tier: Int
    var purchaseCount: Int
    var costIncreases: Int {
        Int(floor(Double(purchaseCount / 10)))
    }
    var currCount: InfiniteDecimal
    var unlocked: Bool
    
    init(tier: Int) {
        self.tier = tier
        self.purchaseCount = 0
        self.unlocked = tier <= 4
        self.currCount = .zeroDecimal
        self.load()
    }
    
    func load() {
        ClickerGaemData.shared.persistentContainer.viewContext.performAndWait {
            let req = StoredDimensionState.fetchRequest()
            req.fetchLimit = 1
            req.predicate = NSPredicate(format: "tier == %d", self.tier)
            guard let maybeStoredState = try? ClickerGaemData.shared.persistentContainer.viewContext.fetch(req).first else {
                self.storedState = StoredDimensionState(context: ClickerGaemData.shared.persistentContainer.viewContext)
                self.storedState!.tier = Int64(tier)
                self.storedState!.currCount = currCount
                self.storedState!.purchaseCount = Int64(purchaseCount)
                self.storedState!.unlocked = unlocked
                return
            }
            self.storedState = maybeStoredState
        }
        self.purchaseCount = Int(storedState!.purchaseCount)
        self.unlocked = storedState!.unlocked
        self.currCount = storedState!.currCount as! InfiniteDecimal
    }
    
    func save(objectContext: NSManagedObjectContext, notification: NotificationCenter.Publisher.Output? = nil) {
        if storedState == nil {
            storedState = StoredDimensionState(context: objectContext)
        }
        storedState!.tier = Int64(tier)
        storedState!.purchaseCount = Int64(purchaseCount)
        storedState!.currCount = currCount
        storedState!.unlocked = unlocked
        try? objectContext.save()
    }
    
    func reset(keepUnlocked: Bool = false) {
        self.purchaseCount = 0
        self.currCount = .zeroDecimal
        self.unlocked = keepUnlocked ? unlocked : false
    }
}

extension DimensionState: Comparable {
    static func == (lhs: DimensionState, rhs: DimensionState) -> Bool {
        lhs.tier == rhs.tier
    }
    
    static func < (lhs: DimensionState, rhs: DimensionState) -> Bool {
        return lhs.tier < rhs.tier
    }
}
