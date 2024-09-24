//
//  Game.swift
//  ClickerGaem
//
//  Created by Justin Covell on 9/15/24.
//

import Foundation

/// Right now just exists to setup the main game loop, but may handle more in the future
class GameInstance: Tickable {
    var ticker: Ticker? = nil
    
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

