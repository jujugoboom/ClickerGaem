//
//  InfinityState.swift
//  ClickerGaem
//
//  Created by Justin Covell on 10/1/24.
//
import Foundation
import CoreData

class InfinityState: Saveable {
//    var storedState: StoredInfinityState
    var infinities: InfiniteDecimal = 0
    var infinitiesThisCrunch: InfiniteDecimal = 0
    var infinityPower: InfiniteDecimal = 0
    var totalInfinities: InfiniteDecimal = 0
    
    func load() {
        
    }
    
    func save(objectContext: NSManagedObjectContext, notification: NotificationCenter.Publisher.Output?) {
        
    }
}
