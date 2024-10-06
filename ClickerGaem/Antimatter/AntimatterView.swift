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
    
    private let columns = [GridItem(.adaptive(minimum: 150))]
    
    var body: some View {
        VStack {
            Text("You have \(state.antimatter) antimatter").font(.headline).foregroundStyle(.red)
            Text("You are getting \(state.amPerSecond) AM/s").font(.subheadline)
            HStack {
                Button(action: buyTickspeedUpgrade) {
                    VStack {
                        Text("\(state.ticksPerSecond) ticks/s").font(.subheadline)
                        Text("Buy for \(state.tickspeedUpgradeCost)").font(.caption)
                    }
                }.disabled(state.tickspeedUpgradeCost.gt(other: state.antimatter)).buttonStyle(.bordered)
                Button(action: maxTickspeedUpgrade) {
                    Text("Max").disabled(state.tickspeedUpgradeCost.gt(other: state.antimatter)).font(.subheadline).padding(.vertical, 8)
                }.buttonStyle(.bordered)
            }
            if (state.dimensionBoosts >= 5) {
                    VStack {
                        Text("Dimension sacrifice multiplier: \(state.dimensionSacrificeMul)x")
                        
                            Button(action: buyDimensionSacrifice) {
                                Text("Buy: \(currSacrificeMultiplier)x").font(.subheadline)
                            }.disabled(Dimensions.shared.dimensions[8]!.state.purchaseCount == 0)
                    }
                
            }
            LazyVGrid(columns: columns) {
                ForEach(Dimensions.shared.unlockedDimensions) { dimension in
                    DimensionView(tier: dimension.tier)
                }
            }
            Button(action: buyMaxDimensions) {
                Text("Max all dimensions").font(.subheadline)
            }.buttonStyle(.borderedProminent).disabled((dimensions.first(where: {dimension in dimension.canBuy}) == nil))

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
    Statistics.shared.totalAntimatter = InfiniteDecimal(mantissa: 1, exponent: 200)
    Antimatter.shared.state.dimensionBoosts = 6
    return ContentView()
        .environment(\.managedObjectContext, ClickerGaemData.preview.viewContext)
}
