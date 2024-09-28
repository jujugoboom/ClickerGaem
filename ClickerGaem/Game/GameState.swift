//
//  Item.swift
//  ClickerGaem
//
//  Created by Justin Covell on 9/13/24.
//

import Foundation
import OrderedCollections
import SwiftUICore
import CoreData
import UIKit

protocol Saveable {
    func load()
    func save(objectContext: NSManagedObjectContext, notification: NotificationCenter.Publisher.Output?)
}

extension Saveable {
    
}

/// Main game state store. is going to get much worse before it gets better
@Observable
final class GameState: Saveable {
    var storedState: StoredGameState?
    var updateInterval: Double = 0.05
    
    var autobuyers: [Autobuyer] = []
    
    var unlockedAutobuyers: [Autobuyer] {
        autobuyers.filter({$0.unlocked})
    }
    
    var firstInfinity = false
    
    @MainActor
    var simulating = false
    @MainActor
    var currSimulatingTick = 0
    
    func load() {
        // TODO: Store autobuyers
        ClickerGaemData.shared.persistentContainer.viewContext.performAndWait {
            let fetchRequest = StoredGameState.fetchRequest()
            fetchRequest.fetchLimit = 1
            guard let maybeStoredState = try? ClickerGaemData.shared.persistentContainer.viewContext.fetch(fetchRequest).first else {
                storedState = StoredGameState(context: ClickerGaemData.shared.persistentContainer.viewContext)
                storedState!.updateInterval = updateInterval
                return
            }
            storedState = maybeStoredState
        }
        updateInterval = storedState!.updateInterval
        return
    }
    
    func save(objectContext: NSManagedObjectContext, notification: NotificationCenter.Publisher.Output? = nil) {
        if storedState == nil {
            storedState = StoredGameState(context: objectContext)
        }
        storedState!.updateInterval = updateInterval
        storedState!.lastSaveTime = Date().timeIntervalSinceReferenceDate
        try! objectContext.save()
    }
    
    func reset() {
        updateInterval = 0.05
    }
    
    /// Generate initial game state with expected defaults. 
    init(updateInterval: Double = 0.05, autobuyers: [Autobuyer] = []) {
        var initAutoBuyers = autobuyers
        if initAutoBuyers.count == 0 {
            for i in 1...8 {
                initAutoBuyers.append(AMDimensionAutobuyer(tier: i, buyRate: 0.5 + (0.1 * (Double(i) - 1)), purchaseAmount: 10))
            }
        }
        self.autobuyers = initAutoBuyers
        self.updateInterval = updateInterval
        self.load()
    }
}
