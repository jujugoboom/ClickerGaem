//
//  AntimatterView.swift
//  ClickerGaem
//
//  Created by Justin Covell on 9/19/24.
//

import Foundation
import SwiftUI

struct AntimatterView: View {
    let state: GameState
    
    var dimensions: [Dimension] {
        Array(state.dimensions.values)
    }
    
    var body: some View {
        VStack {
            Text("You have \(state.antimatter) antimatter")
            Text("You are getting \(state.amPerSecond) AM/s")
            Text("Total tickspeed: \(state.ticksPerSecond)/s")
            HStack {
                Button(action: buyTickspeedUpgrade) {
                    Text("Buy tickspeed upgrade for \(state.tickspeedUpgradeCost)").contentShape(.rect)
                }.disabled(state.tickspeedUpgradeCost.gt(other: state.antimatter))
                Button(action: maxTickspeedUpgrade) {
                    Text("Max tickspeed").disabled(state.tickspeedUpgradeCost.gt(other: state.antimatter))
                }
            }
            Button(action: buyMaxDimensions) {
                Text("Max all dimensions").disabled((dimensions.first(where: {dimension in dimension.canBuy}) == nil))
            }
            
            List {
                ForEach(state.unlockedDimensions) { dimension in
                    DimensionView(dimension: dimension)
                }
            }
            DimensionBoost(gameState: state)
            AntimatterGalaxy(gameState: state)
            
        }
    }
    
    private func buyTickspeedUpgrade() {
        let antimatter = state.antimatter
        let tickspeedUpgradeCost = state.tickspeedUpgradeCost
        guard antimatter.gte(other: tickspeedUpgradeCost) else {
            return
        }
        state.antimatter = antimatter.sub(value: tickspeedUpgradeCost)
        state.tickSpeedUpgrades = (state.tickSpeedUpgrades.add(value: 1))
    }
    
    private func maxTickspeedUpgrade() {
        while state.antimatter.gte(other: state.tickspeedUpgradeCost) {
            buyTickspeedUpgrade()
        }
    }
    
    private func buyMaxDimensions() {
        dimensions.reversed().forEach() { dimension in
            while dimension.canBuy {
                dimension.buy(count: dimension.howManyCanBuy)
            }
        }
    }
}
