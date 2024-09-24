//
//  BigCrunch.swift
//  ClickerGaem
//
//  Created by Justin Covell on 9/22/24.
//

class BigCrunch {
    var state: GameState
    
    var canBigCrunch: Bool {
        state.antimatter.gte(other: InfiniteDecimal(mantissa: 1.8, exponent: 308))
    }
    
    init() {
        self.state = GameState.shared
    }
    
    func crunch() {
        guard canBigCrunch else {
            return
        }
        state.antimatter = 0
        state.dimensionBoosts = 0
        state.sacrificedDimensions = 0
        state.amGalaxies = 0
        state.tickSpeedUpgrades = 0
        state.firstInfinity = true
        state.dimensions.forEach({$1.reset()})
    }
}
