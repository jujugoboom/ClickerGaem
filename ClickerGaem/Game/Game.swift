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
    private static var _shared: GameInstance?
    static var shared: GameInstance {
        if _shared == nil { _shared = GameInstance() }
        return _shared!
    }
    var state: GameState
    var ticker: Ticker? = nil
    
    init() {
        self.state = GameState()
        self.ticker = Ticker(updateInterval: state.updateInterval, tick: self.tick)
    }
    
    func tick(diff: TimeInterval) {
        for dimension in Dimensions.shared.dimensions.values {
            dimension.tick(diff: diff)
        }
//        for autobuyer in state.autobuyers {
//            autobuyer.tick(diff: diff)
//        }
    }
    
    static func reset() {
        _shared?.state.reset()
        _shared?.state.load()
    }
}

