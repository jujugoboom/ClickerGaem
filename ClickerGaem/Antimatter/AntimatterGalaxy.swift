//
//  AntimatterGalaxy.swift
//  ClickerGaem
//
//  Created by Justin Covell on 9/19/24.
//

import Foundation
import SwiftUI

struct AntimatterGalaxy: View {
    @Environment(GameInstance.self) var gameInstance: GameInstance
    var antimatter: Antimatter {
        gameInstance.antimatter
    }
    var dimensions: Dimensions {
        gameInstance.dimensions
    }
    var galaxyCost: Int {
        80 + antimatter.amGalaxies * 60
    }
    var canBuyGalaxy: Bool {
        dimensions.dimensions[8]?.currCount.gte(other: InfiniteDecimal(integerLiteral: galaxyCost)) ?? false
    }
    var body: some View {
        HStack{
            Text("\(antimatter.amGalaxies) galaxies")
            Button(action: buyGalaxy) {
                Text("\(galaxyCost) 8th dimensions").contentShape(.rect)
            }.disabled(!canBuyGalaxy)
        }
    }
    
    @MainActor
    func buyGalaxy() {
        guard canBuyGalaxy else {
            return
        }
        dimensions.dimensions.values.forEach() { dimension in
            dimension.reset(keepUnlocked: false)
        }
        antimatter.set(amount: 10)
        antimatter.tickSpeedUpgrades = 0
        antimatter.dimensionBoosts = 0
        antimatter.sacrificedDimensions = 0
        antimatter.amGalaxies += 1
    }

}
