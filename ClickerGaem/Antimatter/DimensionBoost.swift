//
//  DimensionSacrifice.swift
//  ClickerGaem
//
//  Created by Justin Covell on 9/19/24.
//

import Foundation
import SwiftUI

struct DimensionBoostView: View {
    @Environment(GameInstance.self) var gameInstance: GameInstance
    var antimatter: Antimatter {
        gameInstance.antimatter
    }
    var dimensions: Dimensions {
        gameInstance.dimensions
    }
    var dimensionBoostCost: [Int: Dimension] {
        guard antimatter.dimensionBoosts >= 4 else {
            return [20: dimensions.dimensions[antimatter.dimensionBoosts + 4]!]
        }
        return [-40 + (15 * antimatter.dimensionBoosts): dimensions.dimensions[8]!]
    }
    
    var canBuyDimensionBoost: Bool {
        return dimensionBoostCost.values.first!.currCount.gte(other: InfiniteDecimal(integerLiteral: dimensionBoostCost.keys.first!))
    }
    var strCost: String {
        guard antimatter.dimensionBoosts >= 4 else {
            return "20 \(antimatter.dimensionBoosts + 4)th dimensions"
        }
        return "\(dimensionBoostCost.keys.first!) 8th dimensions"
    }
    var body: some View {
        HStack{
            Text("\(antimatter.dimensionBoosts) dimension boosts")
            Button(action: buyDimensionBoost) {
                Text(strCost).contentShape(.rect)
            }.disabled(!canBuyDimensionBoost)
        }
    }
    
    @MainActor
    func buyDimensionBoost() {
        guard canBuyDimensionBoost else {
            return
        }
        dimensions.dimensions.values.forEach() { dimension in
            dimension.reset(keepUnlocked: true)
        }
        antimatter.set(amount: 10)
        antimatter.tickSpeedUpgrades = 0
        antimatter.dimensionBoosts += 1
        antimatter.sacrificedDimensions = 0
        dimensions.dimensions[antimatter.dimensionBoosts + 4]?.unlocked = true
    }
}
