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
        Button(action: buy) {
            VStack {
                VStack {
                    Text("\(tierFormatter.string(from: dimensionState.tier as NSNumber) ?? "0th") dimension")
                    HStack{
                        Text("Total: \(dimension.state.currCount.floor())").font(.system(size: 10))
                        Text("Purchased: \(dimension.state.purchaseCount)").font(.system(size: 10))
                    }
                    HStack{
                        Text("+\(dimension.growthRate)%/s").font(.system(size: 10))
                        Text("Multiplier \(dimension.multiplier)x").font(.system(size: 10))
                    }
                }
                VStack {
                    Text("Buy \(dimension.howManyCanBuy.toInt())")
                    Text("\(dimension.cost.mul(value: dimension.howManyCanBuy.max(other: 1)))").font(.system(size: 10))
                }.contentShape(.rect)
            }.frame(maxWidth: .infinity)
        }.disabled(!dimension.canBuy).animation(.spring, value: dimension.howManyCanBuy).buttonStyle(.bordered)
    }
                
    private func buy() {
        dimension.buy(count: dimension.howManyCanBuy)
    }
}

#Preview {
    DimensionView(tier: 1)
}
