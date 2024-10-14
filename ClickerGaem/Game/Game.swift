//
//  Game.swift
//  ClickerGaem
//
//  Created by Justin Covell on 9/15/24.
//

import Foundation
import CoreData

protocol Resettable {
    static func reset() async
}

protocol Saveable {
    func load()
    func save(objectContext: NSManagedObjectContext, notification: NotificationCenter.Publisher.Output?)
}

extension Saveable {
    
}

/// Main game model
@Observable
class GameInstance: Saveable {
    var storedState: StoredGameState?
    var updateInterval: Double = 0.05
    
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
    
    var ticker: Ticker.DisplayTicker? = nil
    var saveTicker: Ticker? = nil
    
    var statistics: Statistics
    var antimatter: Antimatter
    var infinity: Infinity
    var achievements: Achievements
    var autobuyers: Autobuyers
    
    init(updateInterval: Double = 0.05) {
        self.updateInterval = updateInterval
        let statistics = Statistics()
        let infinity = Infinity(statistics: statistics)
        let antimatter = Antimatter(infinity: infinity, statistics: statistics)
        let autobuyers = Autobuyers(antimatter: antimatter, statistics: statistics)
        let achievements = Achievements(antimatter: antimatter)
        self.statistics = statistics
        self.infinity = infinity
        self.antimatter = antimatter
        self.autobuyers = autobuyers
        self.achievements = achievements
        self.load()
        self.ticker = Ticker.DisplayTicker(updateInterval: updateInterval, tick: self.tick)
        self.saveTicker = Ticker(updateInterval: 5, tick: self.saveTick)
        self.saveTicker?.startTimer()
    }
    
    func simulateSinceLastSave() {
        guard let lastSave = storedState?.lastSaveTime else { return }
        let timeOffline = Date.timeIntervalSinceReferenceDate - lastSave
        print("Offline for \(timeOffline)s")
        guard timeOffline > 5 else {
            // Don't show the UI for short simulations
            DispatchQueue.main.asyncAndWait {
                ticker?.stopTimer()
            }
            simulate(diff: timeOffline, maxTicks: 10000)
            DispatchQueue.main.asyncAndWait {
                currSimulatingTick = 0
                ticker?.startTimer()
            }
            return
        }
        DispatchQueue.main.asyncAndWait {
            ticker?.stopTimer()
            self.simulating = true
        }
        simulate(diff: timeOffline, maxTicks: 1000)
        DispatchQueue.main.asyncAndWait {
            simulating = false
            currSimulatingTick = 0

            ticker?.startTimer()
        }
    }
    
    private func simulate(diff: TimeInterval, maxTicks: Int) {
        var ticks = maxTicks
        var perTick = diff / Double(ticks)
        if perTick < updateInterval {
            perTick = updateInterval
            ticks = Int(diff / perTick)
        }
        for i in 0...ticks {
            DispatchQueue.main.asyncAndWait {
                tick(diff: perTick)
                self.currSimulatingTick = i
            }
        }
    }
    
    func tick(diff: TimeInterval) {
        antimatter.tick(diff: diff)
        for autobuyer in autobuyers.enabledAutobuyers {
            autobuyer.tick(diff: diff)
        }
    }
    
    func saveTick(diff: TimeInterval) {
        saveGame()
    }
    
    func saveGame() {
        ClickerGaemData.shared.persistentContainer.viewContext.performAndWait {
            let context = ClickerGaemData.shared.persistentContainer.viewContext
            antimatter.save(objectContext: context)
            achievements.achievements.forEach({$0.save(objectContext: context)})
            autobuyers.autobuyers.forEach({$0.save(objectContext: context, notification: nil)})
            self.save(objectContext: context)
        }
    }
}

