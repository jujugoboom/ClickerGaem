//
//  DimensionView.swift
//  ClickerGaem
//
//  Created by Justin Covell on 9/16/24.
//

import SwiftUI

struct DimensionView: View {
    let dimension: Dimension
    var dimensionState: DimensionState {
        self.dimension.state
    }
    
    var cost: InfiniteDecimal {
        self.dimension.cost
    }
    var howManyCanBuy: InfiniteDecimal {
        self.dimension.howManyCanBuy
    }
    
    var tierFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .ordinal
        return formatter
    }
    
    init(dimension: Dimension) {
        self.dimension = dimension
    }
    
    var body: some View {
        HStack {
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
            Spacer()
            Button(action: buy) {
                Text("Buy \(dimension.howManyCanBuy.toInt()) for \(dimension.howManyCanBuy.gt(other: 0) ? cost.mul(value: howManyCanBuy) : cost)").contentShape(.rect).disabled(!dimension.canBuy)
            }
        }
    }
                
    private func buy() {
        dimension.buy(count: dimension.howManyCanBuy)
    }
}

#Preview {
    DimensionView(dimension: Dimension(state: DimensionState(tier: 1, purchaseCount: 0, currCount: 0, unlocked: true), gameState: GameState(antimatter: 1e35)))
}
