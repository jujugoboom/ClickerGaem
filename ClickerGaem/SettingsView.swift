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
        GameInstance.shared.ticker?.stopTimer()
        GameInstance.shared.saveTicker?.stopTimer()
        
        let dimensionsReq = NSFetchRequest<NSFetchRequestResult>(entityName: "StoredDimensionState")
        let dimensionDeleteReq = NSBatchDeleteRequest(fetchRequest: dimensionsReq)
        let achievementsReq = NSFetchRequest<NSFetchRequestResult>(entityName: "StoredAchievementState")
        let achievementDeleteReq = NSBatchDeleteRequest(fetchRequest: achievementsReq)
        let gameReq = NSFetchRequest<NSFetchRequestResult>(entityName: "StoredGameState")
        let gameDeleteReq = NSBatchDeleteRequest(fetchRequest: gameReq)
        let antimatterReq = NSFetchRequest<NSFetchRequestResult>(entityName: "StoredAntimatterState")
        let antimatterDeleteReq = NSBatchDeleteRequest(fetchRequest: antimatterReq)
        let autobuyerReq = NSFetchRequest<NSFetchRequestResult>(entityName: "StoredAutobuyerState")
        let autobuyerDeleteReq = NSBatchDeleteRequest(fetchRequest: autobuyerReq)
        
        do {
            try viewContext.execute(dimensionDeleteReq)
            try viewContext.execute(achievementDeleteReq)
            try viewContext.execute(gameDeleteReq)
            try viewContext.execute(antimatterDeleteReq)
            try viewContext.execute(autobuyerDeleteReq)
            
            try viewContext.save()
            

            GameInstance.reset()
            Antimatter.reset()
            Dimensions.reset()
            Autobuyers.reset()
            // Always do achievements last so they can reset themselves properly
            Achievements.reset()
            
        } catch let error as NSError{
            debugPrint(error)
        }
        // Restart game loop
        GameInstance.shared.ticker?.startTimer()
        GameInstance.shared.saveTicker?.startTimer()
    }
    
}

#Preview {
    SettingsView().environment(\.managedObjectContext, ClickerGaemData.preview.viewContext)
}
