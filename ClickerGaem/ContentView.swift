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

struct SimulatingView: View {
    var body: some View {
        ProgressView(value: Double(GameInstance.shared.state.currSimulatingTick), total: 1000, label: {Text("Simulating offline progress...")}).padding()
    }
}

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.scenePhase) var scenePhase
    var gameState: GameState {
        GameInstance.shared.state
    }
    var bindableGameState: Bindable<GameState> {
        Bindable(GameInstance.shared.state)
    }
    var isSimulating: Binding<Bool> {
        bindableGameState.simulating
    }
    var achievements: Bindable<Achievements> {
        Bindable(Achievements.shared)
    }
    var newAchievementUnlocked: Binding<Bool> {
        achievements.unlockedNewAchievement
    }
    
    @State var modal = true
    
    @State private var currentTab = 1
    
    var body: some View {
        Group {
            if isSimulating.wrappedValue {
                SimulatingView()
            } else {
                TabView(selection: $currentTab) {
                    AntimatterTab().tabItem {
                        Label("Antimatter Dimensions", systemImage: "circle.and.line.horizontal")
                    }.tag(1)
                    if Achievements.shared.unlockedAchievements.count > 0 {
                        AchievementView().tabItem {
                            Label("Achievements", systemImage: "medal.fill")
                        }.tag(2)
                    }
                    SettingsView().environment(\.managedObjectContext, viewContext).tabItem {
                        Label("Settings", systemImage: "gear")
                    }.tag(3)
                }
                .toast(isPresenting: newAchievementUnlocked) {
                    AlertToast(displayMode: .hud, type: .regular, title: Achievements.shared.newAchievementName, subTitle: "Achievement unlocked")
                } onTap: {
                    currentTab = 2
                }
                .saveOnExit()
                .firstBigCrunch()
            }
        }.onChange(of: scenePhase, initial: true) {
            if scenePhase == .active {
                GameInstance.shared.saveTicker?.startTimer()
                Task.detached {
                    GameInstance.shared.simulateSinceLastSave()
                }
            }
            if scenePhase == .inactive || scenePhase == .background {
                GameInstance.shared.saveTicker?.stopTimer()
            }
        }
    }
}

struct SaveOnExit: ViewModifier {
    @Environment(\.managedObjectContext) private var viewContext
    
    func body(content: Content) -> some View {
        content.onReceive(NotificationCenter.default.publisher(for: UIScene.willDeactivateNotification), perform: { _ in
            GameInstance.shared.saveGame()
        }).onReceive(NotificationCenter.default.publisher(for: UIApplication.willTerminateNotification), perform: { _ in
            GameInstance.shared.saveGame()
        })
    }
}

extension View {
    func saveOnExit() -> some View {
        modifier(SaveOnExit())
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, ClickerGaemData.preview.viewContext)
}
