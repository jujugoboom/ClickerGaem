//
//  DimensionState.swift
//  ClickerGaem
//
//  Created by Justin Covell on 9/16/24.
//

import Foundation

/// Main dimension state. 
@Observable
final class DimensionState: ObservableObject {
    let storedState: StoredDimensionState
    let tier: Int
    var purchaseCount: Int
    var costIncreases: Int {
        Int(floor(Double(purchaseCount / 10)))
    }
    var currCount: InfiniteDecimal
    var unlocked: Bool
    
    init(tier: Int, purchaseCount: Int, currCount: InfiniteDecimal, unlocked: Bool) {
        self.tier = tier
        self.purchaseCount = purchaseCount
        self.currCount = currCount
        self.unlocked = unlocked
        self.storedState = StoredDimensionState(context: ClickerGaemData.shared.persistentContainer.viewContext)
    }
    
    init(storedState: StoredDimensionState) {
        self.tier = Int(storedState.tier)
        self.purchaseCount = Int(storedState.purchaseCount)
        self.currCount = storedState.currCount as! InfiniteDecimal
        self.unlocked = storedState.unlocked
        self.storedState = storedState
    }
    
    func save(commit: Bool = false) {
        storedState.tier = Int64(tier)
        storedState.purchaseCount = Int64(purchaseCount)
        storedState.currCount = currCount
        storedState.unlocked = unlocked
        guard commit else {
            return
        }
        try? ClickerGaemData.shared.persistentContainer.viewContext.save()
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
