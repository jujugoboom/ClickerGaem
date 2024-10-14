//
//  Infinity.swift
//  ClickerGaem
//
//  Created by Justin Covell on 10/5/24.
//
import Foundation
import CoreData

@Observable
class Infinity {
    var storedState: StoredInfinityState?
    var infinities: InfiniteDecimal = 0
    var infinitiesThisCrunch: InfiniteDecimal = 0
    var infinityPower: InfiniteDecimal = 0
    var infinityStartTime: Date = Date()
    var infinityBroken = false
    var firstInfinity = false
    
    func load() {
        ClickerGaemData.shared.persistentContainer.viewContext.performAndWait {
            let req = StoredInfinityState.fetchRequest()
            req.fetchLimit = 1
            guard let maybeStoredState = try? ClickerGaemData.shared.persistentContainer.viewContext.fetch(req).first else {
                storedState = StoredInfinityState(context: ClickerGaemData.shared.persistentContainer.viewContext)
                storedState?.infinities = infinities
                storedState?.infinitiesThisCrunch = infinitiesThisCrunch
                storedState?.infinityPower = infinityPower
                storedState?.infinityBroken = infinityBroken
                storedState?.infinityStartTime = infinityStartTime
                storedState?.firstInfinity = firstInfinity
                return
            }
            storedState = maybeStoredState
        }
        infinities = storedState!.infinities as! InfiniteDecimal
        infinitiesThisCrunch = storedState!.infinitiesThisCrunch as! InfiniteDecimal
        infinityPower = storedState!.infinityPower as! InfiniteDecimal
        infinityBroken = storedState!.infinityBroken
        infinityStartTime = storedState?.infinityStartTime ?? Date()
        firstInfinity = storedState!.firstInfinity
    }
    
    func save(objectContext: NSManagedObjectContext, notification: NotificationCenter.Publisher.Output?) {
        if storedState == nil {
            storedState = StoredInfinityState(context: objectContext)
        }
        storedState?.infinities = infinities
        storedState?.infinitiesThisCrunch = infinitiesThisCrunch
        storedState?.infinityPower = infinityPower
        storedState?.infinityBroken = infinityBroken
        storedState?.infinityStartTime = infinityStartTime
        storedState?.firstInfinity = firstInfinity
        try? objectContext.save()
    }
    let infinityUpgrades: InfinityUpgrades
    let statistics: Statistics
    
    var infinityTime: Date = Date.distantPast
    
    init(statistics: Statistics) {
        self.statistics = statistics
        // TODO: Probably a better way to do this
        self.infinityUpgrades = InfinityUpgrades(statistics: statistics)
        self.load()
        self.infinityUpgrades.infinity = { [unowned self] in self}()
    }
    
    func add(infinities: InfiniteDecimal) {
        if !firstInfinity {
            firstInfinity = true
        }
        self.infinities = self.infinities.add(value: infinities)
        statistics.totalInfinities = statistics.totalInfinities.add(value: infinities)
    }
    
    func crunch() {
        add(infinities: 1)
        infinityStartTime = Date()
    }
    
    func reset() {
        infinities = 0
        infinitiesThisCrunch = 0
        infinityPower = 0
        infinityBroken = false
    }
}
