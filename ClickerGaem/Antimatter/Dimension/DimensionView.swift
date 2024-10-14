//
//  DimensionView.swift
//  ClickerGaem
//
//  Created by Justin Covell on 9/16/24.
//

import SwiftUI
import AudioToolbox

struct DimensionView: View {
    @Environment(GameInstance.self) var gameInstance: GameInstance
    var antimatter: Antimatter {
        gameInstance.antimatter
    }
    let tier: Int
    let tierStr: String
    let dimension: Dimension
    
    var howManyCanBuy: InfiniteDecimal {
        dimension.howManyCanBuy(antimatter: antimatter)
    }
    
    var canBuy: Bool {
        antimatter.canBuyDimension(tier)
    }
    
    var multiplier: InfiniteDecimal {
        dimension.multiplier(antimatter: antimatter)
    }
    
    @State var viewingDetails = false
    
    var body: some View {
        Button(action: {}) {
            VStack {
                Text("\(tierStr) dimension")
                HStack{
                    Text("Total: \(dimension.currCount))").font(.system(size: 10))
                    Text("x\(multiplier)").font(.system(size: 10))
                }
                Text("Buy \(howManyCanBuy.toInt())")
                Text("\(dimension.cost.mul(value: howManyCanBuy.max(other: 1)))").font(.system(size: 10))
            }.frame(maxWidth: .infinity, maxHeight: 100)
        }.disabled(!canBuy).buttonStyle(.bordered).simultaneousGesture(LongPressGesture().onEnded {_ in
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            viewingDetails.toggle()
        }).simultaneousGesture(TapGesture().onEnded {_ in
            buy()
        }).popover(isPresented: $viewingDetails) {
            DimensionDetails(dimension: dimension)
        }
    }
    
    init(dimension: Dimension) {
        self.dimension = dimension
        self.tier = dimension.tier
        let formatter = NumberFormatter()
        formatter.numberStyle = .ordinal
        self.tierStr = formatter.string(from: tier as NSNumber) ?? "0th"
    }
                
    private func buy() {
        antimatter.buyDimension(dimension.tier)
    }
}

struct DimensionDetails: View {
    @Environment(GameInstance.self) var gameInstance: GameInstance
    var antimatter: Antimatter {
        gameInstance.antimatter
    }
    let tier: Int
    let tierString: String
    let dimension: Dimension
    
    var growthRate: InfiniteDecimal {
        guard tier != 8 else {
            return 0
        }
        return antimatter.dimensions.dimensions[tier + 1]?.perSecond(antimatter: antimatter).div(value: dimension.currCount.max(other: 1)).mul(value: 100).mul(value: 0.1) ?? 0
    }
    
    var body: some View {
        VStack {
            Text("\(tierString) dimension").font(.title)
            HStack{
                Text("Total: \(dimension.currCount.floor())")
                Text("Purchased: \(dimension.purchaseCount)")
            }
            HStack{
                Text("+\(growthRate)%/s")
                Text("Multiplier x\(dimension.multiplier(antimatter: antimatter))")
            }
        }
    }
    
    init(dimension: Dimension) {
        self.dimension = dimension
        self.tier = dimension.tier
        let formatter = NumberFormatter()
        formatter.numberStyle = .ordinal
        self.tierString = formatter.string(from: tier as NSNumber) ?? "0th"
    }
}

#Preview {
    ClickerGaemData.shared.persistentContainer = ClickerGaemData.preview
    let statistics = Statistics()
    let infinity = Infinity(statistics: statistics)
    let antimatter = Antimatter(infinity: infinity, statistics: statistics)
    
    return DimensionView(dimension: antimatter.dimensions.dimensions[1]!)
}
