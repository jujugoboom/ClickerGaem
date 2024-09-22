//
//  Item.swift
//  ClickerGaem
//
//  Created by Justin Covell on 9/13/24.
//

import Foundation
import OrderedCollections

/// Main game state store. is going to get much worse before it gets better
@Observable final class GameState {
    var updateInterval: Double
    var antimatter: InfiniteDecimal
    var dimensionStates: [DimensionState]
    var tickSpeedUpgrades: InfiniteDecimal = 0
    var dimensionBoosts = 0
    var amGalaxies = 0
    var sacrificedDimensions: InfiniteDecimal = 0
    var dimensionSacrificeMul: InfiniteDecimal {
        GameState.dimensionSacrificeMultiplier(sacrificed: sacrificedDimensions)
    }
    var totalDimensionBoost: InfiniteDecimal {
        (2 as InfiniteDecimal).pow(value: InfiniteDecimal(integerLiteral: dimensionBoosts))
    }
    var ticksPerSecond: InfiniteDecimal {
        InfiniteDecimal(source: 1).add(value: tickSpeedUpgrades.mul(value: InfiniteDecimal(source: 1.125 * max(Double(amGalaxies) * 1.4, 1))))
    }
    var amPerSecond: InfiniteDecimal {
        guard dimensions.keys.contains(1) else {
            return 0
        }
        return dimensions[1]!.perSecond
    }
    
    var dimensions: OrderedDictionary<Int, Dimension> {
        return dimensionStates.reduce(into: [:]) {partialResult, nextValue in
            partialResult[nextValue.tier] = Dimension(state: nextValue, gameState: self)
        }
    }
    
    var unlockedDimensions: [Dimension] {
        dimensions.values.filter() {dimension in
            dimension.state.unlocked
        }
    }
    
    var tickspeedUpgradeCost: InfiniteDecimal {
        InfiniteDecimal().pow10(value: tickSpeedUpgrades.add(value: 3).toDouble())
    }
    
    var autobuyers: [Autobuyer] = []
    
    /// Generate initial game state with expected defaults. 
    init(updateInterval: Double = 0.05, antimatter: InfiniteDecimal = 10, dimensionStates: [DimensionState] = [], autobuyers: [Autobuyer] = []) {
        self.updateInterval = updateInterval
        self.antimatter = antimatter
        var initDimensionStates = dimensionStates
        if initDimensionStates.count == 0 {
            for i in 1...8 {
                initDimensionStates.append(DimensionState(tier: i, purchaseCount: 0, currCount: 0, unlocked: i <= 4))
            }
        }
        self.dimensionStates = initDimensionStates
        var initAutoBuyers = autobuyers
        if initAutoBuyers.count == 0 {
            for i in 1...8 {
                initAutoBuyers.append(AMDimensionAutobuyer(gameState: self, tier: i, buyRate: 0.5 + (0.1 * (Double(i) - 1)), purchaseAmount: 10))
                initAutoBuyers.last?.unlock()
            }
        }
        self.autobuyers = initAutoBuyers
    }
    
    static func dimensionSacrificeMultiplier(sacrificed: InfiniteDecimal) -> InfiniteDecimal {
        InfiniteDecimal(source: sacrificed.log10() / 10).max(other: 1).pow(value: 2)
    }
}
