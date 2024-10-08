//
//  Ticker.swift
//  ClickerGaem
//
//  Created by Justin Covell on 9/15/24.
//

import Foundation
import QuartzCore

/// Basic utility to call a function on a given interval and pass the time since the last call
class Ticker {
    private var timer: Timer? = nil
    let tick: (TimeInterval) -> Void
    var lastRun: Date
    var updateInterval: TimeInterval
    
    init(updateInterval: TimeInterval, tick: @escaping (TimeInterval) -> Void) {
        self.tick = tick
        self.lastRun = Date()
        self.updateInterval = updateInterval
    }
    
    func startTimer() {
        guard self.timer == nil else {
            return
        }
        self.timer = Timer.scheduledTimer(timeInterval: updateInterval, target: self, selector: #selector(self.timerFunc), userInfo: nil, repeats: true)
        RunLoop.current.add(self.timer!, forMode: .common)
        
    }
    
    func stopTimer() {
        guard self.timer != nil else {
            return
        }
        self.timer?.invalidate()
        self.timer = nil
    }
    
    func reset() {
        self.timer?.invalidate()
        self.timer = nil
        self.startTimer()
    }
    
    @objc private func timerFunc(timer: Timer) {
        self.tick(self.lastRun.distance(to: timer.fireDate))
        self.lastRun = timer.fireDate
    }
}

protocol Tickable: Identifiable {
    func tick(diff: TimeInterval)
}

extension Ticker {
    class DisplayTicker: Ticker {
        private var displayTimer: CADisplayLink? = nil
        
        override func startTimer() {
            guard self.displayTimer == nil else {
                return
            }
            displayTimer = CADisplayLink(target: self, selector: #selector(self.displayTick))
            displayTimer?.add(to: .current, forMode: .common)
        }
        
        override func stopTimer() {
            guard displayTimer != nil else {
                return
            }
            displayTimer?.invalidate()
            displayTimer = nil
        }
        
        @objc private func displayTick(timer: CADisplayLink) {
            self.tick(timer.targetTimestamp - timer.timestamp)
        }
    }
}
