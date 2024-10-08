//
//  Antimatter.swift
//  ClickerGaem
//
//  Created by Justin Covell on 9/24/24.
//

class Antimatter: Resettable {
    static var shared = Antimatter()
    let state: AntimatterState
    
    var dimensionBoostCost: [Int: Dimension] {
        guard state.dimensionBoosts >= 4 else {
            return [20: Dimensions.shared.dimensions[state.dimensionBoosts + 4]!]
        }
        return [-40 + (15 * state.dimensionBoosts): Dimensions.shared.dimensions[8]!]
    }
    
    var canBuyDimensionBoost: Bool {
        return dimensionBoostCost.values.first!.state.currCount.gte(other: InfiniteDecimal(integerLiteral: dimensionBoostCost.keys.first!))
    }
    
    var howManyDimensionBoostsCanBuy: InfiniteDecimal {
        if state.dimensionBoosts < 4 {
            if canBuyDimensionBoost { return 1 } else { return 0 }
        }
        return Dimensions.shared.dimensions[8]!.state.currCount.div(value: InfiniteDecimal(integerLiteral: dimensionBoostCost.keys.first!)).floor()
    }
    
    var galaxyCost: Int {
        80 + state.amGalaxies * 60
    }
    
    var canBuyGalaxy: Bool {
        Dimensions.shared.dimensions[8]?.state.currCount.gte(other: InfiniteDecimal(integerLiteral: galaxyCost)) ?? false
    }
    
    init() {
        self.state = AntimatterState()
    }
    
    static func dimensionSacrificeMultiplier(sacrificed: InfiniteDecimal) -> InfiniteDecimal {
        InfiniteDecimal(source: sacrificed.log10() / 10).max(other: 1).pow(value: 2)
    }
    
    func add(amount: InfiniteDecimal) {
        self.state.antimatter = self.state.antimatter.add(value: amount).min(other: Decimals.infinity)
    }
    
    func buyDimensionBoost() {
        guard canBuyDimensionBoost else {
            return
        }
        Dimensions.shared.dimensions.values.forEach() { dimension in
            dimension.reset()
        }
        state.antimatter = 10
        state.tickSpeedUpgrades = 0
        state.dimensionBoosts += 1
        state.sacrificedDimensions = 0
        Dimensions.shared.dimensions[state.dimensionBoosts + 4]?.state.unlocked = true
    }
    
    func buyGalaxy() {
        guard canBuyGalaxy else {
            return
        }
        Dimensions.shared.dimensions.values.forEach() { dimension in
            dimension.reset(keepUnlocked: false)
        }
        state.antimatter = 10
        state.tickSpeedUpgrades = 0
        state.dimensionBoosts = 0
        state.sacrificedDimensions = 0
        state.amGalaxies += 1
    }
    
    static func reset() {
        Antimatter.shared.state.reset()
        Antimatter.shared.state.load()
    }
}
