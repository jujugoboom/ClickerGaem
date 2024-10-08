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
    
    var infinityTime: Date = Date.distantPast
    
    private var _canCrunch = false
    
    var canCrunch: Bool {
        get {
            guard !_canCrunch else {
                return _canCrunch
            }
            _canCrunch = Antimatter.shared.state.antimatter.gte(other: Decimals.infinity)
            guard _canCrunch else {
                return _canCrunch
            }
            infinityTime = Date()
            return _canCrunch
        }
    }
    
    init() {
        state = InfinityState()
    }
    
    func add(infinities: InfiniteDecimal) {
        state.infinities = state.infinities.add(value: infinities)
        Statistics.shared.totalInfinities = Statistics.shared.totalInfinities.add(value: infinities)
    }
    
    func crunch() {
        guard canCrunch else {
            return
        }
        Antimatter.shared.state.reset()
        // Start with 100 instead of 10
        Antimatter.shared.state.antimatter = 100
        Infinity.shared.add(infinities: 1)
        Infinity.shared.state.infinityStartTime = Date()
        Dimensions.shared.dimensions.forEach({$1.reset()})
    }
    
    static func reset() {
        shared.state.infinities = 0
        shared.state.infinitiesThisCrunch = 0
        shared.state.infinityPower = 0
        shared.state.infinityBroken = false
    }
}
