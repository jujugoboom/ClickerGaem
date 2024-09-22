//
//  AutobuyerView.swift
//  ClickerGaem
//
//  Created by Justin Covell on 9/21/24.
//
import SwiftUI

struct AutobuyerView: View {
    var gameState: GameState
    var bindableGameState: Bindable<GameState> {
        Bindable(wrappedValue: gameState)
    }
    var autobuyers: Binding<[Autobuyer]> {
        bindableGameState.autobuyers
    }
    
    let columns: [GridItem] = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var tierFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .ordinal
        return formatter
    }
    
    var body: some View {
        LazyVGrid(columns: columns) {
            ForEach(autobuyers.filter {$0.unlocked.wrappedValue}) {autobuyer in
                VStack{
                    if let adautobuyer = autobuyer.wrappedValue as? AMDimensionAutobuyer {
                        Text("\(tierFormatter.string(from: adautobuyer.tier as NSNumber) ?? "0th") Dimension")
                        Text("Current interval \(adautobuyer.buyRate.formatted())s").font(.system(size: 10))
                        HStack {
                            Button(action: {adautobuyer.toggleEnabled()}) {
                                adautobuyer.enabled ? Label("Enabled", systemImage: "checkmark.circle.fill").labelStyle(.iconOnly) : Label("Disabled", systemImage: "checkmark.circle").labelStyle(.iconOnly)
                            }.padding()
                            Button(action: {adautobuyer.purchaseAmount = adautobuyer.purchaseAmount == 10 ? 1 : 10}) {
                                adautobuyer.purchaseAmount == 10 ? Label("Buys 10", systemImage: "10.square.fill").labelStyle(.iconOnly) : Label("Buys 1", systemImage: "01.square.fill").labelStyle(.iconOnly)
                            }.padding()
                        }.padding()
                    }
                }.padding().background().clipShape(RoundedRectangle(cornerRadius: 10)).shadow(radius: 5)
            }
        }.padding()
    }
}

#Preview {
    AutobuyerView(gameState: GameState())
}
