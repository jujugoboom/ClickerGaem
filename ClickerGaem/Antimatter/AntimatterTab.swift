//
//  AntimatterTab.swift
//  ClickerGaem
//
//  Created by Justin Covell on 9/29/24.
//
import SwiftUI
import OrderedCollections

struct AntimatterTab: View {
    @Environment(GameInstance.self) var gameInstance: GameInstance
    var statistics: Statistics {
        gameInstance.statistics
    }
    @State var currTab = 1
    
    var unlockedViews: OrderedDictionary<String, String> {
        var unlocked: OrderedDictionary<String, String> = ["dimensions": "Antimatter Dimensions"]
        if statistics.totalAntimatter.gte(other: Decimals.e40) {
            unlocked["autobuyers"] = "Autobuyers"
        }
        return unlocked
    }
    var body: some View {
        TabView(selection: $currTab) {
            AntimatterView().tabItem {
                Label("Antimatter Dimensions", systemImage: "circle.and.line.horizontal")
            }.tag(1).environment(gameInstance)
            if statistics.totalAntimatter.gte(other: Decimals.e40) {
                AMAutobuyerView().tabItem {
                    Label("Autobuyers", systemImage: "autostartstop")
                }.tag(2)
            }
        }
    }
}
