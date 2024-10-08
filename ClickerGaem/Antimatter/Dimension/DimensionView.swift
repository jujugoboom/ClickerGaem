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
    
    @State var viewingDetails = false
    
    var body: some View {
        Button(action: {}) {
            VStack {
                Text("\(tierFormatter.string(from: dimensionState.tier as NSNumber) ?? "0th") dimension")
                HStack{
                    Text("Total: \(dimension.state.currCount.floor())").font(.system(size: 10))
                    Text("x\(dimension.multiplier)").font(.system(size: 10))
                }
                Text("Buy \(dimension.howManyCanBuy.toInt())")
                Text("\(dimension.cost.mul(value: dimension.howManyCanBuy.max(other: 1)))").font(.system(size: 10))
            }.frame(maxWidth: .infinity, maxHeight: 100)
        }.disabled(!dimension.canBuy).animation(.spring, value: dimension.howManyCanBuy).buttonStyle(.bordered).simultaneousGesture(LongPressGesture().onEnded {_ in 
            viewingDetails.toggle()
        }).simultaneousGesture(TapGesture().onEnded {_ in
            buy()
        }).popover(isPresented: $viewingDetails) {
            DimensionDetails(tier: tier)
        }
    }
                
    private func buy() {
        dimension.buy(count: dimension.howManyCanBuy)
    }
}

struct DimensionDetails: View {
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
        VStack {
            Text("\(tierFormatter.string(from: dimensionState.tier as NSNumber) ?? "0th") dimension").font(.title)
            HStack{
                Text("Total: \(dimension.state.currCount.floor())")
                Text("Purchased: \(dimension.state.purchaseCount)")
            }
            HStack{
                Text("+\(dimension.growthRate)%/s")
                Text("Multiplier x\(dimension.multiplier)")
            }
        }

    }
}

#Preview {
    ClickerGaemData.shared.persistentContainer = ClickerGaemData.preview
    return DimensionView(tier: 1)
}
