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
    var enabled: Bool = false
    var unlocked: Bool = false
    
    func tick(diff: TimeInterval) {}
    
    func unlock() {
        unlocked = true
    }
    
    func toggleEnabled() {
        enabled = !enabled
    }
}
