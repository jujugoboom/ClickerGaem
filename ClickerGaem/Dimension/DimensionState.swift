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
