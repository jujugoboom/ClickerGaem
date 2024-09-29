//
//  AMDimensionAutobuyer.swift
//  ClickerGaem
//
//  Created by Justin Covell on 9/21/24.
//
import Foundation

@Observable class AMDimensionAutobuyer: BuyableAutobuyer {
    var state: AutobuyerState
    var buyableState: BuyableAutobuyerState {
        state as! BuyableAutobuyerState
    }
    
    var type: AutobuyerType = .amdimension
    
    var gameState: GameState {GameInstance.shared.state}
    var tier: Int
    var cost: InfiniteDecimal {
        Decimals.e10.pow(value: InfiniteDecimal(integerLiteral: tier - 1)).mul(value: Decimals.e40);
    }
    var purchaseableCount: InfiniteDecimal {
        Dimensions.shared.dimensions[tier]?.howManyCanBuy ?? InfiniteDecimal.zeroDecimal
    }
    var buyRate: Double {
        [500, 600, 700, 800, 900, 1000, 1100, 1200][tier] / 1000
    }
    
    var canBuy: Bool {
        return Antimatter.shared.state.totalAntimatter.gte(other: cost)
    }
    
    var elapsedSinceBuy: Double = 0
    
    init(tier: Int, purchaseAmount: Int = 10) {
        self.tier = tier
        self.type = .amdimension
        self.state = BuyableAutobuyerState(id: "dimension-autobuyer-\(tier)")
        state.load()
        self.state.unlocked = true
        if self.state.autobuyCount == 0 {
            self.state.autobuyCount = purchaseAmount
        }
    }
    
    func tick(diff: TimeInterval) {
        guard state.enabled && state.unlocked else {
            return
        }
        // Update our total diff time
        elapsedSinceBuy += diff
        guard elapsedSinceBuy > buyRate else {
            return
        }
        // Reset our timer
        elapsedSinceBuy = 0
        // Check we can buy how many we want
        guard purchaseableCount.gte(other: InfiniteDecimal(integerLiteral: state.autobuyCount)) else {
            return
        }
        Dimensions.shared.dimensions[tier]?.buy(count: InfiniteDecimal(integerLiteral: state.autobuyCount))
    }
    
    
}
