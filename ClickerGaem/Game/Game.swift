//
//  Game.swift
//  ClickerGaem
//
//  Created by Justin Covell on 9/15/24.
//

import Foundation

/// Right now just exists to setup the main game loop, but may handle more in the future
class GameInstance {
    let state: GameState
    var ticker: Ticker? = nil
    
    init(state: GameState) {
        self.state = state
        self.ticker = Ticker(updateInterval: state.updateInterval, tick: self.tick)
    }
    
    func tick(diff: TimeInterval) {
        for dimension in state.dimensions.values {
            dimension.tick(diff: diff)
        }
    }
}

