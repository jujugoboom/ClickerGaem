//
//  AntimatterGalaxy.swift
//  ClickerGaem
//
//  Created by Justin Covell on 9/19/24.
//

import Foundation
import SwiftUI

struct AntimatterGalaxy: View {
    let gameState: GameState = GameState.shared
    
    var cost: Int {
        80 + gameState.amGalaxies * 60
    }
    
    var canBuy: Bool {
        gameState.dimensions[8]?.state.currCount.gte(other: InfiniteDecimal(integerLiteral: cost)) ?? false
    }
    
    var body: some View {
        HStack{
            Text("You have \(gameState.amGalaxies) galaxies")
            Button(action: buy) {
                Text("\(cost) 8th dimensions").contentShape(.rect)
            }.disabled(!canBuy)
        }
    }
    
    private func buy() {
        guard canBuy else {
            return
        }
        gameState.dimensions.values.forEach() { dimension in
            dimension.reset(keepUnlocked: false)
        }
        gameState.antimatter = 10
        gameState.tickSpeedUpgrades = 0
        gameState.dimensionBoosts = 0
        gameState.sacrificedDimensions = 0
        gameState.amGalaxies += 1
    }
}
