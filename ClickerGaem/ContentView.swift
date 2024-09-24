//
//  ContentView.swift
//  ClickerGaem
//
//  Created by Justin Covell on 9/13/24.
//

import SwiftUI
import CoreData
import OrderedCollections
import AlertToast

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    let gameState: GameState = GameState.shared
    var achievements: Bindable<Achievements> {
        Bindable(Achievements.shared)
    }
    var newAchievementUnlocked: Binding<Bool> {
        achievements.unlockedNewAchievement
    }
    
    @State private var currentTab = 1
    
    var body: some View {
        TabView(selection: $currentTab) {
            AntimatterView().tabItem {
                Label("Antimatter Dimensions", systemImage: "circle.and.line.horizontal")
            }.tag(1)
            if Achievements.shared.unlockedAchievements.count > 0 {
                AchievementView().tabItem {
                    Label("Achievements", systemImage: "medal.fill")
                }.tag(2)
            }
            if gameState.unlockedAutobuyers.count > 0 { AutobuyerView().tabItem {
                    Label("Autobuyers", systemImage: "autostartstop")
                }.tag(3)
            }
        }.toast(isPresenting: newAchievementUnlocked) {
            AlertToast(displayMode: .hud, type: .regular, title: Achievements.shared.newAchievementName, subTitle: "Achievement unlocked")
        } onTap: {
            currentTab = 2
        }
    }
    
//    private func initGame() {
//        do {
//            let initState = try viewContext.fetch(NSFetchRequest<StoredGameState>(entityName: "StoredGameState"))
//            if initState.isEmpty {
//                let newState = GameState(antimatter: InfiniteDecimal(mantissa: 1, exponent: 200))
//                state = newState
//            } else {
//                let storedState = initState[0]
//                let storedDimensionStates = storedState.dimensionStates?.allObjects as? [StoredDimensionState] ?? []
//                var dimensionStates: [DimensionState] = []
//                for storedDimensionState in storedDimensionStates {
//                    dimensionStates.append(DimensionState(tier: Int(storedDimensionState.tier), purchaseCount: Int(storedDimensionState.purchaseCount), currCount: storedDimensionState.currCount as! InfiniteDecimal, unlocked: storedDimensionState.unlocked))
//                }
//                state = GameState(updateInterval: storedState.updateInterval, antimatter: storedState.antimatter as! InfiniteDecimal, dimensionStates: dimensionStates)
//            }
//        } catch {
//            assertionFailure("Failed to generate initial state")
//            return
//        }
//    game = GameInstance(state: GameState.shared)
//    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, ClickerGaemData.preview.viewContext)
}
