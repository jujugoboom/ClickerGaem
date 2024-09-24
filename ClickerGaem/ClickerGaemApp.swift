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
    @State private var game = GameInstance()

    var body: some Scene {
        WindowGroup {
            ContentView().environment(\.managedObjectContext, clickerGaemData.persistentContainer.viewContext)
        }
    }
    
    init() {
        _ = game
    }
}
