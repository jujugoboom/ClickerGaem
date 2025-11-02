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
    var storedStatistics: StoredStatistics?
    var totalAntimatter: InfiniteDecimal = 10
    var totalInfinities: InfiniteDecimal = 0
    var startDate: Date = Date()
    var bestAMs: InfiniteDecimal = 0
    var bestInfinitiesS: InfiniteDecimal = 0
    var fastestInfinity: Double = Double.infinity
    var bestIPMsWithoutMaxAll: InfiniteDecimal = 0
    
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
    
    init() {
        self.load()
    }
    
    func save(objectContext: NSManagedObjectContext, notification: NotificationCenter.Publisher.Output?) {
        if storedStatistics == nil {
            storedStatistics = StoredStatistics(context: objectContext)
        }
        storedStatistics?.totalAntimatter = totalAntimatter
        storedStatistics?.totalInfinities = totalInfinities
        storedStatistics?.bestAMs = bestAMs
        storedStatistics?.bestInfinitiesS = bestInfinitiesS
        storedStatistics?.fastestInfinity = fastestInfinity
        try? objectContext.save()
    }
    func load() {
        ClickerGaemData.shared.persistentContainer.viewContext.performAndWait {
            let req = StoredStatistics.fetchRequest()
            req.fetchLimit = 1
            guard let maybeStored = try? ClickerGaemData.shared.persistentContainer.viewContext.fetch(req).first else {
                storedStatistics = StoredStatistics(context: ClickerGaemData.shared.persistentContainer.viewContext)
                storedStatistics?.totalAntimatter = totalAntimatter
                storedStatistics?.totalInfinities = totalInfinities
                storedStatistics?.bestAMs = bestAMs
                storedStatistics?.bestInfinitiesS = bestInfinitiesS
                storedStatistics?.fastestInfinity = fastestInfinity
                return
            }
            storedStatistics = maybeStored
        }
        totalAntimatter = storedStatistics!.totalAntimatter as! InfiniteDecimal
        totalInfinities = storedStatistics!.totalInfinities as! InfiniteDecimal
        bestAMs = storedStatistics!.bestAMs as! InfiniteDecimal
        bestInfinitiesS = storedStatistics!.bestInfinitiesS as! InfiniteDecimal
        fastestInfinity = storedStatistics!.fastestInfinity
    }
}
