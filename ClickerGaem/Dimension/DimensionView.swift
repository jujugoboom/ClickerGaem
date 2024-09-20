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
            Text("\(tierFormatter.string(from: dimensionState.tier as NSNumber) ?? "0th") dimension\n\(dimensionState.currCount)")
            Spacer()
            Button(action: buy) {
                Text("Buy \(dimension.howManyCanBuy.description) for \(dimension.howManyCanBuy.gt(other: 0) ? cost.mul(value: howManyCanBuy) : cost)")
            }.disabled(!dimension.canBuy)
        }
    }
                
    private func buy() {
        dimension.buy(count: dimension.howManyCanBuy)
    }
}

#Preview {
    DimensionView(dimension: Dimension(state: DimensionState(tier: 1, purchaseCount: 0, currCount: 0, unlocked: true), gameState: GameState()))
}
