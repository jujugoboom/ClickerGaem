//
//  InfinityUpgrades.swift
//  ClickerGaem
//
//  Created by Justin Covell on 10/1/24.
//
import Foundation
import CoreData

class InfinityUpgrade: Saveable {
//    var storedInfinityUpgradeState: StoredInfinityUpgradeState?
    var bought = false
    var id: String;
    var cost: InfiniteDecimal;
    var effect: () -> InfiniteDecimal
    var requirements: (() -> Bool)?
    
    init(bought: Bool = false, id: String, cost: InfiniteDecimal, requirements: (() -> Bool)? = nil, effect: @escaping () -> InfiniteDecimal) {
        self.bought = bought
        self.id = id
        self.cost = cost
        self.effect = effect
        self.requirements = requirements
    }
    
    func load() {
        
    }
    
    func save(objectContext: NSManagedObjectContext, notification: NotificationCenter.Publisher.Output?) {
        
    }
}

class InfinityUpgrades {
    static var shared = InfinityUpgrades()
    
    let totalTimeMult = InfinityUpgrade(id: "timeMult", cost: 1) {
        InfiniteDecimal(source: pow(abs(Statistics.shared.startDate.timeIntervalSinceNow) / 2, 0.15))
    }
    
    static func dimInfinityMult() -> InfiniteDecimal {
        Statistics.shared.totalInfinities.mul(value: 0.2).add(value: 1)
    }
    
    let dim18Mult = InfinityUpgrade(id: "18Mult", cost: 1, requirements: {shared.totalTimeMult.bought}) {
        InfinityUpgrades.dimInfinityMult()
    }
    
    let dim27Mult = InfinityUpgrade(id: "27Mult", cost: 1, requirements: {shared.dim18Mult.bought}) {
        InfinityUpgrades.dimInfinityMult()
    }
    
    let dim36Mult = InfinityUpgrade(id: "36Mult", cost: 1, requirements: {shared.dim27Mult.bought}) {
        InfinityUpgrades.dimInfinityMult()
    }
    
    let dim45Mult = InfinityUpgrade(id: "45Mult", cost: 1, requirements: {shared.dim36Mult.bought}) {
        InfinityUpgrades.dimInfinityMult()
    }
    
    
}
