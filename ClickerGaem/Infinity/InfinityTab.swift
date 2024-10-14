//
//  InfinityTab.swift
//  ClickerGaem
//
//  Created by Justin Covell on 10/7/24.
//
import SwiftUI

struct InfinityTab: View {
    @Environment(GameInstance.self) var gameInstance
    var infinity: Infinity { gameInstance.infinity }
    @State var currTab = 1
    var body: some View {
        VStack {
            Text("\(infinity.infinities) infinities")
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
    let gameInstance = GameInstance()
    gameInstance.infinityUpgrades.totalTimeMult.bought = true
    gameInstance.infinity.infinities = 10
    return InfinityTab().environment(gameInstance)
}
