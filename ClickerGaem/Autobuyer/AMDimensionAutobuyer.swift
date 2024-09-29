//
//  AMDimensionAutobuyer.swift
//  ClickerGaem
//
//  Created by Justin Covell on 9/21/24.
//
import Foundation

@Observable class AMDimensionAutobuyer: Autobuyer {
    var gameState: GameState {GameInstance.shared.state}
    var tier: Int
    var cost: InfiniteDecimal {
        Decimals.e10.pow(value: InfiniteDecimal(integerLiteral: tier - 1)).mul(value: Decimals.e40);
    }
    var unlocked: Bool {
        Antimatter.shared.state.totalAntimatter.gte(other: cost)
    }
    var purchaseableCount: InfiniteDecimal {
        Dimensions.shared.dimensions[tier]?.howManyCanBuy ?? InfiniteDecimal.zeroDecimal
    }
    var buyRate: Double {
        [500, 600, 700, 800, 900, 1000, 1100, 1200][tier] / 1000
    }
    var purchaseAmount: InfiniteDecimal
    var elapsedSinceBuy: Double = 0
    
    init(tier: Int, purchaseAmount: InfiniteDecimal = 10) {
        self.tier = tier
        self.purchaseAmount = purchaseAmount
        super.init()
        self.type = .amdimension
    }
    
    override func tick(diff: TimeInterval) {
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
        guard purchaseableCount.gte(other: purchaseAmount) else {
            return
        }
        Dimensions.shared.dimensions[tier]?.buy(count: purchaseAmount)
    }
    
    
}
