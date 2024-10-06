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
        NavigationSplitView {
            List(selection: $selectedView) {
                ForEach(Array(unlockedViews.keys), id: \.self) { key in
                    NavigationLink(value: key) {
                        Text(unlockedViews[key]!)
                    }
                }
            }
        } detail: {
            ZStack {
                if let selectedView {
                    switch selectedView {
                    case "dimensions":
                        AntimatterView().navigationBarBackButtonHidden(unlockedViews.keys.count == 1)
                    case "autobuyers":
                        AMAutobuyerView()
                    default:
                        EmptyView()
                    }
                }
            }
        }
    }
}
