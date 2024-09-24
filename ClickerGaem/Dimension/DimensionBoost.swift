//
//  DimensionSacrifice.swift
//  ClickerGaem
//
//  Created by Justin Covell on 9/19/24.
//

import Foundation
import SwiftUI

struct DimensionBoost {
    let gameState: GameState = GameState.shared
    var howManyCanBuy: InfiniteDecimal {
        if gameState.dimensionBoosts < 4 {
            if canBuy { return 1 } else { return 0 }
        }
        return gameState.dimensions[8]!.state.currCount.div(value: InfiniteDecimal(integerLiteral: cost.keys.first!)).floor()
    }
    
    var cost: [Int: Dimension] {
        guard gameState.dimensionBoosts >= 4 else {
            return [20: gameState.dimensions[gameState.dimensionBoosts + 4]!]
        }
        return [-40 + (15 * gameState.dimensionBoosts): gameState.dimensions[8]!]
    }
    
    var strCost: String {
        guard gameState.dimensionBoosts >= 4 else {
            return "20 \(gameState.dimensionBoosts + 4)th dimensions"
        }
        return "\(cost.keys.first!) 8th dimensions"
    }
    
    var canBuy: Bool {
        return cost.values.first!.state.currCount.gte(other: InfiniteDecimal(integerLiteral: cost.keys.first!))
    }
    
    var body: some View {
        HStack{
            Text("You have \(gameState.dimensionBoosts) dimension boosts")
            Button(action: buy) {
                Text(strCost).contentShape(.rect)
            }.disabled(!canBuy)
        }
    }
    
    func buy() {
        guard canBuy else {
            return
        }
        gameState.dimensions.values.forEach() { dimension in
            dimension.reset()
        }
        gameState.antimatter = 10
        gameState.tickSpeedUpgrades = 0
        gameState.dimensionBoosts += 1
        gameState.sacrificedDimensions = 0
        gameState.dimensions[gameState.dimensionBoosts + 4]?.state.unlocked = true
    }
}

struct DimensionBoostView: View {
    var gameState: GameState = GameState.shared
    var dimensionBoost: DimensionBoost = DimensionBoost()
    var body: some View {
        HStack{
            Text("You have \(gameState.dimensionBoosts) dimension boosts")
            Button(action: dimensionBoost.buy) {
                Text(dimensionBoost.strCost).contentShape(.rect)
            }.disabled(!dimensionBoost.canBuy)
        }
    }}
