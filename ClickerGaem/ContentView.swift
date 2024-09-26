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
    var gameState: GameState {
        GameInstance.shared.state
    }
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
            SettingsView().environment(\.managedObjectContext, viewContext).tabItem {
                Label("Settings", systemImage: "gear")
            }.tag(4)
        }
        .toast(isPresenting: newAchievementUnlocked) {
            AlertToast(displayMode: .hud, type: .regular, title: Achievements.shared.newAchievementName, subTitle: "Achievement unlocked")
        } onTap: {
            currentTab = 2
        }.saveOnExit(saveable: GameInstance.shared.state)
    }
}

struct SaveOnExit: ViewModifier {
    @Environment(\.managedObjectContext) private var viewContext
    let saveable: Saveable
    
    func body(content: Content) -> some View {
        content.onReceive(NotificationCenter.default.publisher(for: UIScene.willDeactivateNotification), perform: { _ in
            saveable.save(objectContext: viewContext)
        }).onReceive(NotificationCenter.default.publisher(for: UIApplication.willTerminateNotification), perform: { _ in
            saveable.save(objectContext: viewContext)
        })
    }
}

extension View {
    func saveOnExit(saveable: Saveable) -> some View {
        modifier(SaveOnExit(saveable: saveable))
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, ClickerGaemData.preview.viewContext)
}
