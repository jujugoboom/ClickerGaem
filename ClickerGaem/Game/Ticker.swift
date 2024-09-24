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
        self.timer = Timer.scheduledTimer(timeInterval: updateInterval, target: self, selector: #selector(timerFunc), userInfo: nil, repeats: true)
        RunLoop.current.add(self.timer!, forMode: .common)
    }
    
    @objc private func timerFunc(timer: Timer) {
        self.tick(self.lastRun.distance(to: timer.fireDate))
        self.lastRun = Date()
    }
}

protocol Tickable: Identifiable {
    func tick(diff: TimeInterval)
}
