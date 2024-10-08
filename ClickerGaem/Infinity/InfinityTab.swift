//
//  InfinityTab.swift
//  ClickerGaem
//
//  Created by Justin Covell on 10/7/24.
//
import SwiftUI

struct InfinityTab: View {
    @State var currTab = 1
    var body: some View {
        VStack {
            Text("\(Infinity.shared.state.infinities) infinities")
            TabView(selection: $currTab) {
                InfinityUpgradesView().tabItem {
                    Label("Infinity Upgrades", systemImage: "infinity")
                }.tag(1)
            }
        }
    }
}

#Preview {
    ClickerGaemData.shared.persistentContainer = ClickerGaemData.preview
    _ = InfinityUpgrades.shared
    InfinityUpgrades.shared.totalTimeMult.bought = true
    Infinity.shared.state.infinities = 10
    return InfinityTab()
}
