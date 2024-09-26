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
    var purchaseableCount: InfiniteDecimal {
        Dimensions.shared.dimensions[tier]?.howManyCanBuy ?? InfiniteDecimal.zeroDecimal
    }
    var buyRate: Double
    var purchaseAmount: InfiniteDecimal
    var elapsedSinceBuy: Double = 0
    
    init(tier: Int, buyRate: Double, purchaseAmount: InfiniteDecimal) {
        self.tier = tier
        self.buyRate = buyRate
        self.purchaseAmount = purchaseAmount
        super.init()
        self.type = .amdimension
    }
    
    override func tick(diff: TimeInterval) {
        guard enabled && unlocked else {
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
