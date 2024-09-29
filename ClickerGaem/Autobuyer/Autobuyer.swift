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

@Observable class Autobuyer: Identifiable, Tickable {
    var type: AutobuyerType = .none
    var state: AutobuyerState = AutobuyerState()
    
    func tick(diff: TimeInterval) {}
    
    func unlock() {
        state.unlocked = true
    }
    
    func toggleEnabled() {
        state.enabled = !state.enabled
    }
}

class Autobuyers: Tickable {
    static let shared = Autobuyers()
    let autobuyers: [Autobuyer] = []
    
    func tick(diff: TimeInterval) {
        autobuyers.forEach({$0.tick(diff: diff)})
    }
}
