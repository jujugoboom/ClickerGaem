//
//  Game.swift
//  ClickerGaem
//
//  Created by Justin Covell on 9/15/24.
//

import Foundation

/// Right now just exists to setup the main game loop, but may handle more in the future
@MainActor
class GameInstance {
    static let shared = GameInstance()
    var ticker: Ticker? = nil
    
    func reset() {
        self.ticker?.updateInterval = GameState.shared.updateInterval
        self.ticker?.reset()
    }
    
    @MainActor
    init() {
        if !GameState.load() {
            GameState.initState()
        }
        self.ticker = Ticker(updateInterval: GameState.shared.updateInterval, tick: self.tick)
        _ = Achievements()
    }
    
    func tick(diff: TimeInterval) {
        for dimension in GameState.shared.dimensions.values {
            dimension.tick(diff: diff)
        }
        for autobuyer in GameState.shared.autobuyers {
            autobuyer.tick(diff: diff)
        }
    }
}

