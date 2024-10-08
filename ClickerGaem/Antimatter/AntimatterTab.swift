//
//  AntimatterTab.swift
//  ClickerGaem
//
//  Created by Justin Covell on 9/29/24.
//
import SwiftUI
import OrderedCollections

struct AntimatterTab: View {
    @State var selectedView: String? = "dimensions"
    var unlockedViews: OrderedDictionary<String, String> {
        var unlocked: OrderedDictionary<String, String> = ["dimensions": "Antimatter Dimensions"]
        if Statistics.shared.totalAntimatter.gte(other: Decimals.e40) {
            unlocked["autobuyers"] = "Autobuyers"
        }
        return unlocked
    }
    var body: some View {
        TabView {
            AntimatterView().tabItem {
                Label("Antimatter Dimensions", systemImage: "circle.and.line.horizontal")
            }
            if Statistics.shared.totalAntimatter.gte(other: Decimals.e40) {
                AMAutobuyerView().tabItem {
                    Label("Autobuyers", systemImage: "autostartstop")
                }
            }
        }
    }
}
