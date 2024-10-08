//
//  InfinityState.swift
//  ClickerGaem
//
//  Created by Justin Covell on 10/1/24.
//
import Foundation
import CoreData

class InfinityState: Saveable {
    var storedState: StoredInfinityState?
    var infinities: InfiniteDecimal = 0
    var infinitiesThisCrunch: InfiniteDecimal = 0
    var infinityPower: InfiniteDecimal = 0
    var infinityStartTime: Date = Date()
    var infinityBroken = false
    var firstInfinity = false
    
    init() {
        self.load()
    }
    
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
}
