//
//  Dimension.swift
//  ClickerGaem
//
//  Created by Justin Covell on 9/15/24.
//

import Foundation

/// Main dimension class. Setup expecting that there are a max of 8 dimensions, and will fail if set to a 9th tier
class Dimension: Identifiable {
    let tierPrices: [Int: InfiniteDecimal] = [1: 10, 2: 100, 3: 10000, 4: 1e6, 5: 1e9, 6: 1e13, 7: 1e18, 8: 1e24]
    let basePriceIncreases: [Int: InfiniteDecimal] = [1: 1e3, 2: 5e3, 3: 1e4, 4: 1.2e4, 5: 1.8e4, 6: 2.6e4, 7: 3.2e4, 8: 4.2e4]
    
    var state: DimensionState
    let gameState: GameState
    
    var tier: Int {
        state.tier
    }
    
    var timesBought: InfiniteDecimal {
        InfiniteDecimal(integerLiteral: state.purchaseCount / 10).floor()
    }
    
    var dimensionBoostMultiplier: InfiniteDecimal {
        guard tier >= gameState.dimensionBoosts else {
            return 1
        }
        return InfiniteDecimal(integerLiteral: 2).pow(value: InfiniteDecimal(integerLiteral: gameState.dimensionBoosts))
    }
    
    var multiplier: InfiniteDecimal {
        timesBought.mul(value: 2).max(other: 1).mul(value: dimensionBoostMultiplier)
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
        let ratio = gameState.antimatter.div(value: cost)
        return ratio.min(other: InfiniteDecimal(integerLiteral: 10 - boughtBefore10)).max(other: 0).floor()
    }
    
    var canBuy: Bool {
        howManyCanBuy.gt(other: 0)
    }
    
    init(state: DimensionState, gameState: GameState) {
        self.state = state
        self.gameState = gameState
    }
    
    /// Tries to buy a count of this dimension, returns no information about the success of such an attempt
    func buy(count: InfiniteDecimal) {
        if count.gt(other: howManyCanBuy) {
            return
        }
        gameState.antimatter = gameState.antimatter.sub(value: cost.mul(value: count))
        let intCount = count.toInt()
        state.purchaseCount += intCount
        state.currCount = state.currCount.add(value: count)
        if tier < 8 && state.purchaseCount == 10 {
            guard tier < 3 || gameState.dimensionBoosts >= tier - 3 else {
                return
            }
            gameState.dimensions[tier + 1]?.state.unlocked = true
        }
    }
    
    /// Handle the last time interval for just this dimension
    /// For 1st dimension generate antimatter, and calculate current AM/s
    /// For 2nd-8th, generate tier-1 dimensions
    func tick(diff: TimeInterval) {
        guard state.purchaseCount > 0 else {
            return
        }
        if tier == 1 {
            gameState.antimatter = gameState.antimatter.add(value: state.currCount.mul(value: gameState.ticksPerSecond.mul(value: InfiniteDecimal(source: diff))).mul(value: multiplier))
            gameState.amPerSecond = state.currCount.mul(value: gameState.ticksPerSecond).mul(value: multiplier)
        } else {
            // Get dimension the tier below this one
            let lowerDimension = gameState.dimensions[tier - 1]!
            lowerDimension.state.currCount = lowerDimension.state.currCount.add(value: state.currCount.mul(value: gameState.ticksPerSecond.mul(value: InfiniteDecimal(source: diff))).mul(value: multiplier))
        }
    }
    
    func reset() {
        self.state.purchaseCount = 0
        self.state.currCount = 0
        self.state.unlocked = self.state.tier == 1
    }
}
