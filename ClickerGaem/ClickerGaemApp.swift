//
//  ClickerGaemApp.swift
//  ClickerGaem
//
//  Created by Justin Covell on 9/13/24.
//

import SwiftUI
import CoreData

@main
struct ClickerGaemApp: App {
    @StateObject private var clickerGaemData = ClickerGaemData.shared

    var body: some Scene {
        WindowGroup {
            ContentView().environment(\.managedObjectContext, clickerGaemData.persistentContainer.viewContext)
        }
    }
    
    init() {
        _ = GameInstance.shared
        _ = Antimatter.shared
        _ = Dimensions.shared
        _ = Infinity.shared
        _ = InfinityUpgrades.shared
        _ = Autobuyers.shared
        _ = Achievements.shared
        _ = Statistics.shared
        GameInstance.shared.ticker?.startTimer()
    }
}
