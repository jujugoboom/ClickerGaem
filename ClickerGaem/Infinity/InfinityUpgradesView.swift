//
//  InfinityUpgradesView.swift
//  ClickerGaem
//
//  Created by Justin Covell on 10/6/24.
//
import SwiftUI

struct InfinityUpgradeButton: View {
    @State var upgrade: InfinityUpgrade
    
    var body: some View {
        Button(action: upgrade.buy) {
            VStack {
                Text(upgrade.description)
                if (upgrade.bought) {
                    Text("Currently: \(upgrade.effect())")
                }
            }.padding().minimumScaleFactor(0.5).frame(width: 180, height: 200).foregroundStyle(.white)
        }.background(content: {RoundedRectangle(cornerRadius: 10).foregroundStyle(upgrade.bought ? .yellow : upgrade.canBuy ? .blue : .gray)}).padding().disabled(upgrade.bought || !upgrade.canBuy)
    }
}

struct InfinityUpgradesView: View {
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())]) {
                ForEach(InfinityUpgrades.shared.upgrades) { upgrade in
                    InfinityUpgradeButton(upgrade: upgrade)
                }
            }
        }
    }
}

#Preview {
    ClickerGaemData.shared.persistentContainer = ClickerGaemData.preview
    _ = InfinityUpgrades.shared
    InfinityUpgrades.shared.totalTimeMult.bought = true
    Infinity.shared.state.infinities = 10
    return InfinityUpgradesView()
}
