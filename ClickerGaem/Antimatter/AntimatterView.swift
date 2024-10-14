//
//  AntimatterView.swift
//  ClickerGaem
//
//  Created by Justin Covell on 9/19/24.
//

import Foundation
import SwiftUI
import OrderedCollections


struct AntimatterView: View {
    @Environment(GameInstance.self) var gameInstance
    var antimatter: Antimatter {
        gameInstance.antimatter
    }
    
    var dimensions: [Dimension] {
        Array(antimatter.dimensions.dimensions.values)
    }
    
    var currSacrificeMultiplier: InfiniteDecimal {
        Antimatter.dimensionSacrificeMultiplier(sacrificed: antimatter.sacrificedDimensions.add(value: dimensions.first?.currCount ?? 0)).div(value: antimatter.dimensionSacrificeMul)
    }
    
    private let columns = [GridItem(.adaptive(minimum: 150))]
    
    
    var body: some View {
        VStack {
            Text("You have \(antimatter.antimatter) antimatter").font(.headline).foregroundStyle(.red).animation(.smooth, value: antimatter.antimatter)
            Text("You are getting \(antimatter.amPerSecond) AM/s").font(.subheadline).animation(.smooth, value: antimatter.amPerSecond)
            HStack {
                Button(action: buyTickspeedUpgrade) {
                    VStack {
                        Text("\(antimatter.ticksPerSecond) ticks/s").font(.subheadline)
                        Text("Buy for \(antimatter.tickspeedUpgradeCost)").font(.caption)
                    }.animation(.smooth, value: antimatter.ticksPerSecond)
                }.disabled(antimatter.tickspeedUpgradeCost.gt(other: antimatter.antimatter)).buttonStyle(.bordered)
                Button(action: maxTickspeedUpgrade) {
                    Text("Max").disabled(antimatter.tickspeedUpgradeCost.gt(other: antimatter.antimatter)).font(.subheadline).padding(.vertical, 8)
                }.buttonStyle(.bordered)
            }
            if (antimatter.dimensionBoosts >= 5) {
                    VStack {
                        Text("Dimension sacrifice multiplier: \(antimatter.dimensionSacrificeMul)x")
                        
                            Button(action: buyDimensionSacrifice) {
                                Text("Buy: \(currSacrificeMultiplier)x").font(.subheadline)
                            }.disabled(antimatter.dimensions.dimensions[8]!.purchaseCount == 0)
                    }
                
            }
            LazyVGrid(columns: columns) {
                ForEach(antimatter.dimensions.unlockedDimensions) { dimension in
                    DimensionView(dimension: dimension)
                }
            }
            Button(action: buyMaxDimensions) {
                Text("Max all dimensions").font(.subheadline)
            }.buttonStyle(.borderedProminent).disabled((dimensions.first(where: {dimension in antimatter.canBuyDimension(dimension.tier)}) == nil))

            Spacer()
            DimensionBoostView()
            AntimatterGalaxy()
        }.padding()
    }
    
    private func buyTickspeedUpgrade() {
        let antimatter = antimatter.antimatter
        let tickspeedUpgradeCost = self.antimatter.tickspeedUpgradeCost
        guard antimatter.gte(other: tickspeedUpgradeCost) else {
            return
        }
        self.antimatter.antimatter = antimatter.sub(value: tickspeedUpgradeCost)
        self.antimatter.tickSpeedUpgrades = (self.antimatter.tickSpeedUpgrades.add(value: 1))
    }
    
    private func maxTickspeedUpgrade() {
        while self.antimatter.antimatter.gte(other: self.antimatter.tickspeedUpgradeCost) {
            buyTickspeedUpgrade()
        }
    }
    
    private func buyMaxDimensions() {
        dimensions.reversed().forEach() { dimension in
            while self.antimatter.canBuyDimension(dimension.tier) {
                antimatter.buyDimension(dimension.tier)
            }
        }
    }
    
    private func buyDimensionSacrifice() {
        guard self.antimatter.dimensionBoosts >= 5 else {
            return
        }
        guard let firstDimension = dimensions.first else {
            return
        }
        self.antimatter.sacrificedDimensions = self.antimatter.sacrificedDimensions.add(value: firstDimension.currCount)
        for dimension in dimensions {
            guard dimension.tier != 8 else {
                continue
            }
            dimension.currCount = 0
        }
    }
}

#Preview {
    ClickerGaemData.shared.persistentContainer = ClickerGaemData.preview
    let statistics = Statistics()
    let infinity = Infinity(statistics: statistics)
    let antimatter = Antimatter(infinity: infinity, statistics: statistics)
    statistics.totalAntimatter = InfiniteDecimal(mantissa: 1, exponent: 200)
    antimatter.dimensionBoosts = 6
    return ContentView()
        .environment(\.managedObjectContext, ClickerGaemData.preview.viewContext).environment(statistics).environment(infinity).environment(antimatter)
}
