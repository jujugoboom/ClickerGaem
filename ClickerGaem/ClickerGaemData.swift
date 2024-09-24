//
//  ClickerGaemData.swift
//  ClickerGaem
//
//  Created by Justin Covell on 9/18/24.
//

import Foundation
import CoreData

class ClickerGaemData: ObservableObject {
    static let shared = ClickerGaemData()
    
    static var preview: NSPersistentContainer {
        InfiniteDecimalTransformer.register()
        let container = NSPersistentContainer(name: "ClickerGaemModel")
        container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        container.loadPersistentStores { _, error in
            if let error {
                // Handle the error appropriately. However, it's useful to use
                // `fatalError(_:file:line:)` during development.
                fatalError("Failed to load persistent stores: \(error.localizedDescription)")
            }
        }
        
        let gameState = GameState.shared
        let storedGameState = StoredGameState(context: container.viewContext)
        storedGameState.antimatter = gameState.antimatter
        gameState.dimensionStates.forEach { dimensionState in
            let storedDimensionState = StoredDimensionState(context: container.viewContext)
            storedDimensionState.currCount = dimensionState.currCount
            storedDimensionState.purchaseCount = Int64(dimensionState.purchaseCount)
            storedDimensionState.tier = Int64(dimensionState.tier)
            storedDimensionState.unlocked = dimensionState.unlocked
            storedGameState.addToDimensionStates(storedDimensionState)
        }
        storedGameState.ticksPerSecond = gameState.ticksPerSecond
        storedGameState.updateInterval = gameState.updateInterval
        
        return container
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
        InfiniteDecimalTransformer.register()
        // Pass the data model filename to the container’s initializer.
        let container = NSPersistentContainer(name: "ClickerGaemModel")
        
        // Load any persistent stores, which creates a store if none exists.
        container.loadPersistentStores { _, error in
            if let error {
                // Handle the error appropriately. However, it's useful to use
                // `fatalError(_:file:line:)` during development.
                fatalError("Failed to load persistent stores: \(error.localizedDescription)")
            }
        }
        return container
    }()
    
    private init() {}
}
