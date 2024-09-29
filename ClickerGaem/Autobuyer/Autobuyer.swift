//
//  Autobuyer.swift
//  ClickerGaem
//
//  Created by Justin Covell on 9/21/24.
//

import Foundation

enum AutobuyerType {
    case amdimension
    case none
}

protocol Autobuyer: Identifiable, Tickable {
    var type: AutobuyerType { get set }
    var state: AutobuyerState { get set }
    
    func unlock()
    func toggleEnabled()
}

extension Autobuyer {
    func tick(diff: TimeInterval) {}
    
    func unlock() {
        state.unlocked = true
    }
    
    func toggleEnabled() {
        state.enabled = !state.enabled
    }
}

protocol BuyableAutobuyer: Autobuyer {
    var buyableState: BuyableAutobuyerState { get }
    
    var canBuy: Bool { get }
    
    func purchase()
}

extension BuyableAutobuyer {
   func purchase() {
       guard canBuy else { return }
       buyableState.purchased = true
   }
}

class Autobuyers: Tickable, Resettable {
    static let shared = Autobuyers()
    let dimensionAutobuyers: [AMDimensionAutobuyer] = (1...8).map({AMDimensionAutobuyer(tier: $0)})
    var autobuyers: [any Autobuyer] = []
    var unlockedAutobuyers: [any Autobuyer] {
        autobuyers.filter({$0.state.unlocked})
    }
    var enabledAutobuyers: [any Autobuyer] {
        autobuyers.filter({$0.state.unlocked && $0.state.enabled})
    }
    
    init () {
        autobuyers.append(contentsOf: dimensionAutobuyers)
    }
    
    func tick(diff: TimeInterval) {
        autobuyers.forEach({$0.tick(diff: diff)})
    }
    
    static func reset() {
        Autobuyers.shared.autobuyers.forEach({$0.state.reset()})
    }
}
