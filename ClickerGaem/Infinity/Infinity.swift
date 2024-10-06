//
//  Infinity.swift
//  ClickerGaem
//
//  Created by Justin Covell on 10/5/24.
//
import Foundation

@Observable
class Infinity: Resettable {
    static let shared = Infinity()
    
    let state: InfinityState
    
    init() {
        state = InfinityState()
    }
    
    func add(infinities: InfiniteDecimal) {
        state.infinities = state.infinities.add(value: infinities)
        Statistics.shared.totalInfinities = Statistics.shared.totalInfinities.add(value: infinities)
    }
    
    static func reset() {
        shared.state.infinities = 0
        shared.state.infinitiesThisCrunch = 0
        shared.state.infinityPower = 0
        shared.state.infinityBroken = false
    }
}
