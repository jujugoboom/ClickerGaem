//
//  ClickerGaemApp.swift
//  ClickerGaem
//
//  Created by Justin Covell on 9/13/24.
//

import SwiftUI
import CoreData

struct GameReset: EnvironmentKey {
    static var defaultValue: () -> Void = {}
}

extension EnvironmentValues {
    var gameReset: () -> Void {
        get { self[GameReset.self] }
        set { self[GameReset.self] = newValue }
    }
}

@main
struct ClickerGaemApp: App {
    @StateObject private var clickerGaemData = ClickerGaemData.shared
    @State private var gameInstance: GameInstance
//    @State private var shouldReset = false {
//        didSet {
//            print("Maybe resetting game")
//            if shouldReset {
//                print("Resetting game")
//                gameInstance = GameInstance()
//                gameInstance.ticker?.startTimer()
//                shouldReset = false
//            }
//        }
//    }

    var body: some Scene {
        WindowGroup {
            ContentView().environment(gameInstance).environment(\.managedObjectContext, clickerGaemData.persistentContainer.viewContext).environment(\.gameReset, reset)
        }
    }
    
    func reset() {
        gameInstance = GameInstance()
        gameInstance.ticker?.startTimer()
    }
    
    init() {
        gameInstance = GameInstance()
        gameInstance.ticker?.startTimer()
//        _ = GameInstance.shared
//        _ = Antimatter.shared
//        _ = Dimensions.shared
//        _ = Infinity.shared
//        _ = InfinityUpgrades.shared
//        _ = Autobuyers.shared
//        _ = Achievements.shared
//        _ = Statistics.shared
//        GameInstance.shared.ticker?.startTimer()
    }
}
