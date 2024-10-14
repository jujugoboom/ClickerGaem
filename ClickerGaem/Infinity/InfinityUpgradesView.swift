//
//  InfinityUpgradesView.swift
//  ClickerGaem
//
//  Created by Justin Covell on 10/6/24.
//
import SwiftUI

struct InfinityUpgradeButton: View {
    let upgrade: InfinityUpgrade
    let infinity: Infinity
    
    var canBuy: Bool {
        upgrade.requirements?() ?? true && !upgrade.bought && infinity.infinities.gte(other: upgrade.cost)
    }
    
    var body: some View {
        Button(action: buy) {
            VStack {
                Text(upgrade.description)
                if (upgrade.bought) {
                    Text("Currently: \((upgrade.effect ?? {1})())")
                }
            }.padding().minimumScaleFactor(0.5).frame(width: 180, height: 200).foregroundStyle(.white)
        }.background(content: {RoundedRectangle(cornerRadius: 10).foregroundStyle(upgrade.bought ? .yellow : canBuy ? .blue : .gray)}).padding().disabled(upgrade.bought || !canBuy)
    }
    
    func buy() {
        guard canBuy else {
            return
        }
        infinity.infinities = infinity.infinities.sub(value: upgrade.cost)
        upgrade.bought = true
    }

}

struct InfinityUpgradesView: View {
    @Environment(GameInstance.self) var gameInstance: GameInstance
    var infinity: Infinity {
        gameInstance.infinity
    }
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())]) {
                ForEach(infinity.infinityUpgrades.upgrades) { upgrade in
                    InfinityUpgradeButton(upgrade: upgrade, infinity: infinity)
                }
            }
        }
    }
}

#Preview {
    ClickerGaemData.shared.persistentContainer = ClickerGaemData.preview
    let gameInstance = GameInstance()
    let infinity = gameInstance.infinity
    infinity.infinityUpgrades.totalTimeMult.bought = true
    infinity.infinities = 10
    return InfinityUpgradesView().environment(gameInstance)
}
