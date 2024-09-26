//
//  DimensionView.swift
//  ClickerGaem
//
//  Created by Justin Covell on 9/16/24.
//

import SwiftUI

struct DimensionView: View {
    var tier: Int
    var dimension: Dimension {
        Dimensions.shared.dimensions[tier]!
    }
    var dimensionState: DimensionState {
        self.dimension.state
    }
    
    var tierFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .ordinal
        return formatter
    }
    
    var body: some View {
        HStack(spacing: 20) {
            VStack {
                Text("\(tierFormatter.string(from: dimensionState.tier as NSNumber) ?? "0th") dimension")
                HStack{
                    Text("Total: \(dimension.state.currCount.description)").font(.system(size: 10))
                    Text("+\(dimension.growthRate)%/s").font(.system(size: 10))
                }
                HStack{
                    Text("Purchased: \(dimension.state.purchaseCount)").font(.system(size: 10))
                    Text("Multiplier \(dimension.multiplier)x").font(.system(size: 10))
                }
            }
            Button(action: buy) {
                VStack {
                    Text("Buy \(dimension.howManyCanBuy.toInt())")
                    Text("\(dimension.cost.mul(value: dimension.howManyCanBuy.max(other: 1)))").font(.system(size: 10))
                }.contentShape(.rect)
            }.disabled(!dimension.canBuy).buttonStyle(.bordered).animation(.spring, value: dimension.canBuy)
        }.saveOnExit(saveable: dimension.state)
    }
                
    private func buy() {
        dimension.buy(count: dimension.howManyCanBuy)
    }
}

#Preview {
    DimensionView(tier: 1)
}
