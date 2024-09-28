//
//  Dimension.swift
//  ClickerGaem
//
//  Created by Justin Covell on 9/15/24.
//

import Foundation
import OrderedCollections

/// Main dimension class. Setup expecting that there are a max of 8 dimensions, and will fail if set to a 9th tier
@Observable
class Dimension: Identifiable, Tickable {
    let tierPrices: [Int: InfiniteDecimal] = [1: 10, 2: 100, 3: 10000, 4: 1e6, 5: 1e9, 6: 1e13, 7: 1e18, 8: 1e24]
    let basePriceIncreases: [Int: InfiniteDecimal] = [1: 1e3, 2: 1e4, 3: 1e5, 4: 1e6, 5: 1e8, 6: 1e10, 7: 1e12, 8: 1e15]
    
    var state: DimensionState
    var storedState: StoredDimensionState?
    var antimatterState: AntimatterState { Antimatter.shared.state }
    
    var tier: Int {
        state.tier
    }
    
    var timesBought: InfiniteDecimal {
        InfiniteDecimal(integerLiteral: state.purchaseCount / 10).floor()
    }
    
    var dimensionBoostMultiplier: InfiniteDecimal {
        guard tier <= antimatterState.dimensionBoosts else {
            return 1
        }
        return InfiniteDecimal(integerLiteral: 2).pow(value: InfiniteDecimal(integerLiteral: antimatterState.dimensionBoosts))
    }
    
    var multiplier: InfiniteDecimal {
        var val = timesBought.mul(value: 2).max(other: 1).mul(value: dimensionBoostMultiplier)
        if tier == 8 {
            val = val.mul(value: antimatterState.dimensionSacrificeMul)
        }
        return val
    }
    
    var cost: InfiniteDecimal {
        let priceIncrease = basePriceIncreases[tier]?.pow(value: timesBought)
        return tierPrices[tier]?.mul(value: priceIncrease ?? InfiniteDecimal.nanDecimal) ?? InfiniteDecimal.nanDecimal
    }
    
    var boughtBefore10: Int {
        state.purchaseCount % 10
    }
    
    var howManyCanBuy: InfiniteDecimal {
        guard cost.isFinite() else {
            return 0
        }
        let ratio = antimatterState.antimatter.div(value: cost)
        return ratio.min(other: InfiniteDecimal(integerLiteral: 10 - boughtBefore10)).max(other: 0).floor()
    }
    
    var perSecond: InfiniteDecimal {
        state.currCount.mul(value: antimatterState.ticksPerSecond).mul(value: multiplier)
    }
    
    var growthRate: InfiniteDecimal {
        guard tier != 8 else {
            return 0
        }
        return Dimensions.shared.dimensions[tier + 1]?.perSecond.div(value: state.currCount.max(other: 1)).mul(value: 100) ?? 0
    }
    
    var canBuy: Bool {
        state.unlocked && howManyCanBuy.gt(other: 0)
    }
    
    init(tier: Int) {
        self.state = DimensionState(tier: tier)
    }
    
    /// Tries to buy a count of this dimension, returns no information about the success of such an attempt
    func buy(count: InfiniteDecimal) {
        guard count.lte(other: howManyCanBuy) else {
            return
        }
        let totalCost = cost.mul(value: count)
        guard antimatterState.antimatter.gte(other: totalCost) else {
            return
        }
        antimatterState.antimatter = antimatterState.antimatter.sub(value: totalCost)
        let intCount = count.toInt()
        state.purchaseCount += intCount
        state.currCount = state.currCount.add(value: count)
    }
    
    /// Handle the last time interval for just this dimension
    /// For 1st dimension generate antimatter, and calculate current AM/s
    /// For 2nd-8th, generate tier-1 dimensions
    func tick(diff: TimeInterval) {
        guard state.purchaseCount > 0 else {
            return
        }
        if tier == 1 {
            antimatterState.antimatter = antimatterState.antimatter.add(value: perSecond.mul(value: InfiniteDecimal(source: diff)))
        } else {
            // Get dimension the tier below this one
            let lowerDimension = Dimensions.shared.dimensions[tier - 1]!
            lowerDimension.state.currCount = lowerDimension.state.currCount.add(value: perSecond.mul(value: InfiniteDecimal(source: diff / 10)))
        }
    }
    
    func reset(keepUnlocked: Bool = true) {
        self.state.purchaseCount = 0
        self.state.currCount = 0
        if !keepUnlocked {
            self.state.unlocked = tier <= 4
        } else {
            self.state.unlocked = self.state.unlocked
        }
    }
}

@Observable
class Dimensions: Resettable {
    
    private static var _shared: Dimensions?
    static var shared: Dimensions {
        if _shared == nil { _shared = Dimensions() }
        return _shared!
    }
    
    let dimensions: OrderedDictionary<Int, Dimension> = [1: Dimension(tier: 1), 2: Dimension(tier: 2), 3: Dimension(tier: 3), 4: Dimension(tier: 4), 5: Dimension(tier: 5), 6: Dimension(tier: 6), 7: Dimension(tier: 7), 8: Dimension(tier: 8)]
    
    var unlockedDimensions: [Dimension] {
        dimensions.values.filter() {dimension in
            dimension.state.unlocked
        }
    }
    
    static func reset() {
        Dimensions._shared?.dimensions.values.forEach({$0.state.reset(keepUnlocked: false)})
        Dimensions._shared?.dimensions.values.forEach({$0.state.load()})
        Dimensions._shared?.dimensions[1]?.state.unlocked = true
        Dimensions._shared?.dimensions[2]?.state.unlocked = true
        Dimensions._shared?.dimensions[3]?.state.unlocked = true
        Dimensions._shared?.dimensions[4]?.state.unlocked = true
    }
}
