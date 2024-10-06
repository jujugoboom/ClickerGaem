//
//  InfinityUpgrades.swift
//  ClickerGaem
//
//  Created by Justin Covell on 10/1/24.
//
import Foundation
import CoreData

class InfinityUpgrade: Saveable {
    var storedInfinityUpgradeState: StoredInfinityUpgrade?
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
        self.load()
    }
    
    func load() {
        ClickerGaemData.shared.persistentContainer.viewContext.performAndWait {
            let req = StoredInfinityUpgrade.fetchRequest()
            req.fetchLimit = 1
            req.predicate = NSPredicate(format: "id == %@", self.id)
            guard let maybeStored = try? ClickerGaemData.shared.persistentContainer.viewContext.fetch(req).first else {
                self.storedInfinityUpgradeState = StoredInfinityUpgrade(context: ClickerGaemData.shared.persistentContainer.viewContext)
                self.storedInfinityUpgradeState!.id = self.id
                self.storedInfinityUpgradeState!.bought = self.bought
                return
            }
            self.storedInfinityUpgradeState = maybeStored
        }
        self.bought = self.storedInfinityUpgradeState!.bought
    }
    
    func save(objectContext: NSManagedObjectContext, notification: NotificationCenter.Publisher.Output?) {
        if storedInfinityUpgradeState == nil {
            storedInfinityUpgradeState = StoredInfinityUpgrade(context: objectContext)
        }
        storedInfinityUpgradeState!.id = id
        storedInfinityUpgradeState!.bought = bought
        try? objectContext.save()
    }
}

class InfinityUpgrades: Resettable {
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
    
    var upgrades: [InfinityUpgrade] { [totalTimeMult, dim18Mult, dim27Mult, dim36Mult, dim45Mult] }
    
    static func reset() {
        shared.upgrades.forEach({$0.bought = false})
    }
}
