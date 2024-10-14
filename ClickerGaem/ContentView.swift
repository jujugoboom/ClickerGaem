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
    @Environment(GameInstance.self) var gameInstance
    var body: some View {
        ProgressView(value: Double(gameInstance.currSimulatingTick), total: 1000, label: {Text("Simulating offline progress...")}).padding()
    }
}

struct MainNavigation: View {
    @Environment(GameInstance.self) var gameInstance
    @Binding var currentView: String?
    
    private var views: [String] {
        var views = ["Antimatter", "Statistics", "Settings"]
        if gameInstance.achievements.unlockedAchievements.count > 0 {
            views.insert("Achievements", at: 1)
        }
        if gameInstance.infinity.firstInfinity {
            views.insert("Infinity", at: 1)
        }
        return views
    }
    
    var body: some View {
        NavigationSplitView {
            List(views, id: \.self, selection: $currentView) { view in
                NavigationLink(view, value: view)
            }
        } detail: {
            switch currentView {
            case "Antimatter":
                AntimatterTab()
            case "Settings":
                SettingsView()
            case "Achievements":
                AchievementView()
            case "Infinity":
                InfinityTab()
            case "Statistics":
                StatisticsView()
            default:
                Section {
                    EmptyView()
                }
            }
        }
    }
}

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.scenePhase) var scenePhase
    @Environment(GameInstance.self) var gameInstance: GameInstance
    var isSimulating: Bool {
        gameInstance.simulating
    }
    
    var achievements: Bindable<Achievements> {
        Bindable(gameInstance.achievements)
    }
    var newAchievementUnlocked: Binding<Bool> {
        achievements.unlockedNewAchievement
    }
    @State var modal = true
    
    @State var currentView: String?
    
    
    var body: some View {
        Group {
            if isSimulating {
                SimulatingView()
            } else {
                MainNavigation(currentView: $currentView)
            }
        }.onChange(of: scenePhase, initial: true) {
            if scenePhase == .active {
                gameInstance.saveTicker?.startTimer()
                Task.detached {
                    await gameInstance.simulateSinceLastSave()
                }
            }
            if scenePhase == .inactive || scenePhase == .background {
                gameInstance.saveTicker?.stopTimer()
                gameInstance.ticker?.stopTimer()
            }
        }.toast(isPresenting: achievements.unlockedNewAchievement) {
            AlertToast(displayMode: .hud, type: .regular, title: achievements.newAchievementName.wrappedValue, subTitle: "Achievement unlocked")
        } onTap: {
            currentView = "Achievements"
        }
    }
}

struct SaveOnExit: ViewModifier {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(GameInstance.self) private var gameInstance
    
    func body(content: Content) -> some View {
        content.onReceive(NotificationCenter.default.publisher(for: UIScene.willDeactivateNotification), perform: { _ in
            gameInstance.saveGame()
        }).onReceive(NotificationCenter.default.publisher(for: UIApplication.willTerminateNotification), perform: { _ in
            gameInstance.saveGame()
        })
    }
}

extension View {
    func saveOnExit() -> some View {
        modifier(SaveOnExit())
    }
}

#Preview {
    ClickerGaemData.shared.persistentContainer = ClickerGaemData.preview
    return ContentView()
        .environment(\.managedObjectContext, ClickerGaemData.preview.viewContext)
}
