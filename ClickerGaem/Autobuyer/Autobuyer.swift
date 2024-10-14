//
//  Autobuyer.swift
//  ClickerGaem
//
//  Created by Justin Covell on 9/21/24.
//

import Foundation
import CoreData

enum AutobuyerType {
    case amdimension
    case none
}

protocol Autobuyer: AnyObject, Identifiable, Tickable, Saveable {
    var type: AutobuyerType { get set }
    var id: String { get }
    var enabled: Bool { get set }
    var unlocked: Bool { get set }
    var autobuyCount: Int { get set }
    var storedState: StoredAutobuyerState? { get set }
    
    func unlock()
    func toggleEnabled()
}

extension Autobuyer {
    func tick(diff: TimeInterval) {}
    
    func reset() {
        self.enabled = false
        self.unlocked = false
        self.load()
    }
    
    func unlock() {
        unlocked = true
    }
    
    func toggleEnabled() {
        enabled = !enabled
    }
}

protocol BuyableAutobuyer: AnyObject, Autobuyer {
    var purchased: Bool { get set }
    var canBuy: Bool { get }
    
    func purchase()
}

extension BuyableAutobuyer {
    func purchase() {
        guard canBuy else { return }
        purchased = true
    }
}

class Autobuyers: Tickable {
    let dimensionAutobuyers: [AMDimensionAutobuyer]
    var autobuyers: [any Autobuyer] = []
    var unlockedAutobuyers: [any Autobuyer] {
        autobuyers.filter({$0.unlocked})
    }
    var enabledAutobuyers: [any Autobuyer] {
        autobuyers.filter({$0.unlocked && $0.enabled})
    }
    
    init (antimatter: Antimatter, statistics: Statistics) {
        dimensionAutobuyers = (1...8).map({AMDimensionAutobuyer(antimatter: antimatter, statistics: statistics, tier: $0)})
        autobuyers.append(contentsOf: dimensionAutobuyers)
    }
    
    func tick(diff: TimeInterval) {
        autobuyers.forEach({$0.tick(diff: diff)})
    }
    
    func reset() {
        autobuyers.forEach({$0.reset()})
    }
}
