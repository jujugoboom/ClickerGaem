//
//  AMDimensionAutobuyerView.swift
//  ClickerGaem
//
//  Created by Justin Covell on 9/29/24.
//
import SwiftUI

struct AMDimensionAutobuyerView: View {
    let autobuyer: AMDimensionAutobuyer
    
    var tierFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .ordinal
        return formatter
    }
    
    var body: some View {
        VStack{
            if !autobuyer.purchased {
                if !autobuyer.canBuy {
                    Text("Unlocked at \(autobuyer.cost) total AM")
                } else {
                    Button(action: autobuyer.purchase) {
                        Text("Buy")
                    }.buttonStyle(.bordered)
                }
            }
            else  {
                Text("\(tierFormatter.string(from: autobuyer.tier as NSNumber) ?? "0th") Dimension")
                Text("Current interval \(autobuyer.buyRate.formatted())s").font(.system(size: 10))
                HStack(spacing: 30) {
                    Button(action: {autobuyer.toggleEnabled()}) {
                        autobuyer.enabled ? Label("Enabled", systemImage: "checkmark.circle.fill").labelStyle(.iconOnly) : Label("Disabled", systemImage: "checkmark.circle").labelStyle(.iconOnly)
                    }
                    Button(action: {autobuyer.autobuyCount = autobuyer.autobuyCount == 10 ? 1 : 10}) {
                        autobuyer.autobuyCount == 10 ? Label("Buys 10", systemImage: "10.square.fill").labelStyle(.iconOnly) : Label("Buys 1", systemImage: "01.square.fill").labelStyle(.iconOnly)
                    }
                }.padding(.top)
            }
        }.padding().background().clipShape(RoundedRectangle(cornerRadius: 10)).shadow(radius: 5)
    }
}

#Preview {
    ClickerGaemData.shared.persistentContainer = ClickerGaemData.preview
    let gameInstance = GameInstance()
    gameInstance.statistics.totalAntimatter = InfiniteDecimal(mantissa: 1, exponent: 50)
    return AMDimensionAutobuyerView(autobuyer: AMDimensionAutobuyer(antimatter: gameInstance.antimatter, statistics: gameInstance.statistics, tier: 1))
}
