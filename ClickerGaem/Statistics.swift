//
//  Statistics.swift
//  ClickerGaem
//
//  Created by Justin Covell on 10/1/24.
//
import Foundation
import CoreData

@Observable
class Statistics: Saveable {
    static var shared = Statistics()
//    var storedStatistics: StoredStatistics
    var totalAntimatter: InfiniteDecimal = 0
    var totalInfinities: InfiniteDecimal = 0
    var startDate: Date = Date()
    var bestAMs: InfiniteDecimal = 0
    var bestInfinitiesS: InfiniteDecimal = 0
    
    private var _firstInfinity: Bool = false
    var firstInfinity: Bool {
        guard !_firstInfinity else {
            return _firstInfinity
        }
        _firstInfinity = totalInfinities.gte(other: 0)
        return _firstInfinity
    }
    
    func addAntimatter(amount: InfiniteDecimal, diff: TimeInterval) {
        guard amount.gte(other: 0) else {
            return
        }
        totalAntimatter = totalAntimatter.add(value: amount)
        bestAMs = amount.mul(value: InfiniteDecimal(source: 1/diff)).max(other: bestAMs)
    }
    
    func addInfinities(amount: InfiniteDecimal, diff: TimeInterval) {
        guard amount.gte(other: 0) else {
            return
        }
        totalInfinities = totalInfinities.add(value: amount)
        bestInfinitiesS = amount.mul(value: InfiniteDecimal(source: 1/diff)).max(other: bestInfinitiesS)
    }
    
    init() {}
    
    func save(objectContext: NSManagedObjectContext, notification: NotificationCenter.Publisher.Output?) {
        
    }
    func load() {
        
    }
}
