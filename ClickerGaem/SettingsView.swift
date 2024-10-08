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
    let fields: Dictionary<String, (String) -> Void> = ["Antimatter": {val in
        let split = val.split(separator: "e")
        guard split.count == 2, let mantissa = Double(split[0]), let exponent = Int(split[1]) else {
            return
        }
        Antimatter.shared.state.antimatter = InfiniteDecimal(mantissa: mantissa, exponent: exponent, shouldNormalize: true)
    }, "Dimension Boosts": {val in guard let intVal = Int(val) else {
        return
    }
        Antimatter.shared.state.dimensionBoosts = intVal
    }, "Galaxies": {val in guard let intVal = Int(val) else {
        return
    }
        Antimatter.shared.state.amGalaxies = intVal
    }]
    @Environment(\.managedObjectContext) private var viewContext
    @State private var wantToDelete = false
    @State private var fieldToUpdate = "Antimatter"
    @State private var updateValue = ""
    var body: some View {
        List {
            Button(role: .destructive, action: {wantToDelete = true }){
                Label("Delete save", systemImage: "trash").foregroundStyle(.red).padding()
            }
            Picker("Pick a field to update", selection: $fieldToUpdate) {
                ForEach(Array(fields.keys), id: \.self) { field in Text(field)}
            }
            HStack {
                TextField("Value", text: $updateValue)
                Button("Save", action: updateSelectedValue).containerShape(.rect)
            }
            Button("Unlock all dimensions", action: {Dimensions.shared.dimensions.values.forEach({$0.state.unlocked = true})})
        }.alert("Are you sure?", isPresented: $wantToDelete) {
            Button(role: .destructive, action: clearSaveData) {
                Text("Delete save data")
            }
        }
        
    }
    
    private func getDeleteRequest(_ entity: String) -> NSBatchDeleteRequest {
        let req = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        return NSBatchDeleteRequest(fetchRequest: req)
    }
    
    private func clearSaveData() {
        GameInstance.shared.ticker?.stopTimer()
        GameInstance.shared.saveTicker?.stopTimer()
        let deleteRequests: [NSBatchDeleteRequest] = ["StoredDimensionState", "StoredAchievementState", "StoredGameState", "StoredAntimatterState", "StoredAutobuyerState", "StoredStatistics", "StoredInfinityState", "StoredInfinityUpgrade"].map({getDeleteRequest($0)})
        do {
            try deleteRequests.forEach({try viewContext.execute($0)})
            
            try viewContext.save()
            
            
            GameInstance.reset()
            Antimatter.reset()
            Dimensions.reset()
            Autobuyers.reset()
            Infinity.reset()
            InfinityUpgrades.reset()
            Statistics.reset()
            // Always do achievements last so they can reset themselves properly
            Achievements.reset()
            
        } catch let error as NSError{
            debugPrint(error)
        }
        // Restart game loop
        GameInstance.shared.ticker?.startTimer()
        GameInstance.shared.saveTicker?.startTimer()
    }
    
    private func updateSelectedValue() {
        guard let setter = fields[fieldToUpdate] else {
            return
        }
        setter(updateValue)
    }
}

#Preview {
    ClickerGaemData.shared.persistentContainer = ClickerGaemData.preview
    return SettingsView().environment(\.managedObjectContext, ClickerGaemData.preview.viewContext)
}
