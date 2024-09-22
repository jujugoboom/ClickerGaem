//
//  Ticker.swift
//  ClickerGaem
//
//  Created by Justin Covell on 9/15/24.
//

import Foundation

/// Basic utility to call a function on a given interval and pass the time since the last call
class Ticker {
    var timer: Timer? = nil
    let tick: (TimeInterval) -> Void
    var lastRun: Date
    
    init(updateInterval: TimeInterval, tick: @escaping (TimeInterval) -> Void) {
        self.tick = tick
        self.lastRun = Date()
        self.timer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) {timer in
            self.tick(self.lastRun.distance(to: timer.fireDate))
            self.lastRun = Date()
        }
    }
}

protocol Tickable: Identifiable {
    func tick(diff: TimeInterval)
}
