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
        GameInstance.shared.ticker?.startTimer()
    }
}
