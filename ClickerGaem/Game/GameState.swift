//
//  Item.swift
//  ClickerGaem
//
//  Created by Justin Covell on 9/13/24.
//

import Foundation
import OrderedCollections
import SwiftUICore

/// Main game state store. is going to get much worse before it gets better
@Observable
final class GameState {
    static let shared = GameState()
    
    var storedState: StoredGameState
    var updateInterval: Double = 0.05
    var antimatter: InfiniteDecimal = 10
    var dimensionStates: [DimensionState] = []
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
    
    var dimensions: OrderedDictionary<Int, Dimension> = [:]
    
    var unlockedDimensions: [Dimension] {
        dimensions.values.filter() {dimension in
            dimension.state.unlocked
        }
    }
    
    var tickspeedUpgradeCost: InfiniteDecimal {
        InfiniteDecimal().pow10(value: tickSpeedUpgrades.add(value: 3).toDouble())
    }
    
    var autobuyers: [Autobuyer] = []
    
    var unlockedAutobuyers: [Autobuyer] {
        autobuyers.filter({$0.unlocked})
    }
    
    var firstInfinity = false
    
    class func load() -> Bool {
        var dimensionStates: [DimensionState] = []
        for dimensionState in shared.storedState.dimensionStates ?? [] {
            let storedDimensionState = dimensionState as! StoredDimensionState
            dimensionStates.append(DimensionState(storedState: storedDimensionState))
        }
        dimensionStates.sort(by: {$0.tier < $1.tier})
        // TODO: Store autobuyers
        // Forcefully casting antimatter here causes preview to crash
        GameState.initState(updateInterval: shared.storedState.updateInterval, antimatter: shared.storedState.antimatter as? InfiniteDecimal ?? 0, dimensionStates: dimensionStates)
        return true
    }
    
    class func save(commit: Bool = true) {
        shared.storedState.updateInterval = shared.updateInterval
        shared.storedState.antimatter = shared.antimatter
        let storedDimensionStates: [StoredDimensionState] = shared.dimensionStates.map(\.storedState)
        shared.dimensionStates.forEach({$0.save()})
        shared.storedState.dimensionStates = NSSet(array: storedDimensionStates)
        Achievements().achievements.forEach({$0.save()})
        guard commit else {
            return
        }
        try! ClickerGaemData.shared.persistentContainer.viewContext.save()
    }
    
    class func initState(updateInterval: Double = 0.05, antimatter: InfiniteDecimal = 10, dimensionStates: [DimensionState] = [], autobuyers: [Autobuyer] = []) {
        shared.updateInterval = updateInterval
        shared.antimatter = antimatter
        var initDimensionStates = dimensionStates
        if initDimensionStates.count == 0 {
            for i in 1...8 {
                initDimensionStates.append(DimensionState(tier: i, purchaseCount: 0, currCount: 0, unlocked: true))
            }
        }
        shared.dimensionStates = initDimensionStates
        shared.dimensions = initDimensionStates.reduce(into: [:]) {partialResult, nextValue in
            partialResult[nextValue.tier] = Dimension(state: nextValue)
        }
        var initAutoBuyers = autobuyers
        if initAutoBuyers.count == 0 {
            for i in 1...8 {
                initAutoBuyers.append(AMDimensionAutobuyer(tier: i, buyRate: 0.5 + (0.1 * (Double(i) - 1)), purchaseAmount: 10))
            }
        }
        shared.autobuyers = initAutoBuyers
    }
    
    /// Generate initial game state with expected defaults. 
    private init() {
        let fetchRequest = StoredGameState.createFetchRequest()
        fetchRequest.fetchLimit = 1
        storedState = (try? ClickerGaemData.shared.persistentContainer.viewContext.fetch(fetchRequest).first) ?? StoredGameState(context: ClickerGaemData.shared.persistentContainer.viewContext)
    }
    
    static func dimensionSacrificeMultiplier(sacrificed: InfiniteDecimal) -> InfiniteDecimal {
        InfiniteDecimal(source: sacrificed.log10() / 10).max(other: 1).pow(value: 2)
    }
}
