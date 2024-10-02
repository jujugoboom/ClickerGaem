//
//  AntimatterView.swift
//  ClickerGaem
//
//  Created by Justin Covell on 9/19/24.
//

import Foundation
import SwiftUI

struct AntimatterView: View {
    var state: AntimatterState {
        Antimatter.shared.state
    }
    
    var dimensions: [Dimension] {
        Array(Dimensions.shared.dimensions.values)
    }
    
    var currSacrificeMultiplier: InfiniteDecimal{
        Antimatter.dimensionSacrificeMultiplier(sacrificed: state.sacrificedDimensions.add(value: dimensions.first?.state.currCount ?? 0)).div(value: state.dimensionSacrificeMul)
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
            if (state.dimensionBoosts >= 5) {
                Button(action: buyDimensionSacrifice) {
                    Text("Buy dimension sacrifice: \(currSacrificeMultiplier)x")
                }
                Text("Current dimension sacrifice multiplier: \(state.dimensionSacrificeMul)x")
            }
            Button(action: buyMaxDimensions) {
                Text("Max all dimensions").disabled((dimensions.first(where: {dimension in dimension.canBuy}) == nil))
            }
            ScrollView {
                VStack(spacing: 25) {
                    ForEach(Dimensions.shared.unlockedDimensions) { dimension in
                        DimensionView(tier: dimension.tier)
                    }
                }.padding()
            }
            Spacer()
            DimensionBoostView()
            AntimatterGalaxy()
        }.padding()
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
    
    private func buyDimensionSacrifice() {
        guard state.dimensionBoosts >= 5 else {
            return
        }
        guard let firstDimension = dimensions.first else {
            return
        }
        state.sacrificedDimensions = state.sacrificedDimensions.add(value: firstDimension.state.currCount)
        for dimension in dimensions {
            guard dimension.tier != 8 else {
                continue
            }
            dimension.state.currCount = 0
        }
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, ClickerGaemData.preview.viewContext)
}
