//
//  SettingsView.swift
//  ClickerGaem
//
//  Created by Justin Covell on 9/24/24.
//

import Foundation
import SwiftUI
import CoreData

struct SettingsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var wantToDelete = false
    var body: some View {
        List {
            Button(role: .destructive, action: {wantToDelete = true }){
                Label("Delete save", systemImage: "trash").foregroundStyle(.red).padding()
            }
        }.alert("Are you sure?", isPresented: $wantToDelete) {
            Button(role: .destructive, action: clearSaveData) {
                Text("Delete save data")
            }
        }
    }
    
    private func clearSaveData() {
        let dimensionsReq = NSFetchRequest<NSFetchRequestResult>(entityName: "StoredDimensionState")
        let dimensionDeleteReq = NSBatchDeleteRequest(fetchRequest: dimensionsReq)
        let achievementsReq = NSFetchRequest<NSFetchRequestResult>(entityName: "StoredAchievementState")
        let achievementDeleteReq = NSBatchDeleteRequest(fetchRequest: achievementsReq)
        let gameReq = NSFetchRequest<NSFetchRequestResult>(entityName: "StoredGameState")
        let gameDeleteReq = NSBatchDeleteRequest(fetchRequest: gameReq)
        
        do {
            try viewContext.execute(dimensionDeleteReq)
            try viewContext.execute(achievementDeleteReq)
            try viewContext.execute(gameDeleteReq)
            
            try viewContext.save()
        } catch let error as NSError{
            debugPrint(error)
        }
        GameState.shared.storedState = StoredGameState(context: viewContext)
        GameState.initState()
        GameInstance.shared.reset()
        Achievements.shared.reload()
    }
}

#Preview {
    SettingsView().environment(\.managedObjectContext, ClickerGaemData.preview.viewContext)
}
