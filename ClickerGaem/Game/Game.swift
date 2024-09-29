//
//  Game.swift
//  ClickerGaem
//
//  Created by Justin Covell on 9/15/24.
//

import Foundation

protocol Resettable {
    static func reset() async
}

/// Right now just exists to setup the main game loop, but may handle more in the future
class GameInstance: Resettable {
    static let shared = GameInstance()
    var state: GameState
    var ticker: Ticker? = nil
    var saveTicker: Ticker? = nil
    
    init() {
        self.state = GameState()
        self.ticker = Ticker(updateInterval: state.updateInterval, tick: self.tick)
        self.saveTicker = Ticker(updateInterval: 5, tick: self.saveTick)
        self.saveTicker?.startTimer()
    }
    
    func simulateSinceLastSave() {
        guard let lastSave = state.storedState?.lastSaveTime else { return }
        let timeOffline = Date.timeIntervalSinceReferenceDate - lastSave
        print("Offline for \(timeOffline)s")
        guard timeOffline > 5 else {
            // Don't show the UI for short simulations
            DispatchQueue.main.asyncAndWait {
                ticker?.stopTimer()
            }
            simulate(diff: timeOffline, maxTicks: 10000)
            DispatchQueue.main.asyncAndWait {
                state.currSimulatingTick = 0
                ticker?.startTimer()
            }
            return
        }
        DispatchQueue.main.asyncAndWait {
            ticker?.stopTimer()
            self.state.simulating = true
        }
        simulate(diff: timeOffline, maxTicks: 1000)
        DispatchQueue.main.asyncAndWait {
            state.simulating = false
            state.currSimulatingTick = 0

            ticker?.startTimer()
        }
    }
    
    private func simulate(diff: TimeInterval, maxTicks: Int) {
        var ticks = maxTicks
        var perTick = diff / Double(ticks)
        if perTick < state.updateInterval {
            perTick = state.updateInterval
            ticks = Int(diff / perTick)
        }
        for i in 0...ticks {
            DispatchQueue.main.asyncAndWait {
                tick(diff: perTick)
                self.state.currSimulatingTick = i
            }
        }
    }
    
    func tick(diff: TimeInterval) {
        for dimension in Dimensions.shared.dimensions.values.reversed() {
            dimension.tick(diff: diff)
        }
        for autobuyer in Autobuyers.shared.enabledAutobuyers {
            autobuyer.tick(diff: diff)
        }
    }
    
    static func reset() {
        shared.state.reset()
        shared.state.load()
    }
    
    func saveTick(diff: TimeInterval) {
        saveGame()
    }
    
    func saveGame() {
        ClickerGaemData.shared.persistentContainer.viewContext.performAndWait {
            let context = ClickerGaemData.shared.persistentContainer.viewContext
            Antimatter.shared.state.save(objectContext: context)
            Dimensions.shared.dimensions.values.forEach({$0.state.save(objectContext: context)})
            Achievements.shared.achievements.forEach({$0.save(objectContext: context)})
            Autobuyers.shared.autobuyers.forEach({$0.state.save(objectContext: context)})
            GameInstance.shared.state.save(objectContext: context)
        }
    }
}

