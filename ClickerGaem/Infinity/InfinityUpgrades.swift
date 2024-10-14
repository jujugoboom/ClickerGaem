//
//  InfinityUpgrades.swift
//  ClickerGaem
//
//  Created by Justin Covell on 10/1/24.
//
import Foundation
import CoreData

@Observable
class InfinityUpgrade: Saveable, Identifiable {
    var storedInfinityUpgradeState: StoredInfinityUpgrade?
    var bought = false
    var id: String
    var description: String
    var cost: InfiniteDecimal
    var effect: (() -> InfiniteDecimal)?
    var requirements: (() -> Bool)?
//
//    var canBuy: Bool {
//        requirements?() ?? true && !bought && Infinity.shared.state.infinities.gte(other: cost)
//    }
    
    init(bought: Bool = false, id: String, description: String, cost: InfiniteDecimal, requirements: (() -> Bool)? = nil, effect: (() -> InfiniteDecimal)? = nil) {
        self.bought = bought
        self.id = id
        self.description = description
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

class InfinityUpgrades {
    let statistics: Statistics
    var infinity: Infinity?
    
    let totalTimeMult: InfinityUpgrade
    
    func dimInfinityMult() -> InfiniteDecimal {
        statistics.totalInfinities.mul(value: 0.2).add(value: 1)
    }
    
    let dim18Mult: InfinityUpgrade
    
    let dim27Mult: InfinityUpgrade
    
    let dim36Mult: InfinityUpgrade
    
    let dim45Mult: InfinityUpgrade
    
    let resetBoost: InfinityUpgrade
    
    let buy10Mult : InfinityUpgrade
    
    let galaxyBoost: InfinityUpgrade
    
    let thisInfinityTimeMult: InfinityUpgrade
    
    let unspentIPMult: InfinityUpgrade
    
    let dimboostMult: InfinityUpgrade
    
    let ipGen: InfinityUpgrade
    
    let skipReset1 = InfinityUpgrade(id: "skipReset1", description: "Start every reset with 1 Dimension Boost, automatically unlocking the 5th Antimatter Dimension", cost: 20, effect: {1})
    
    let skipReset2 = InfinityUpgrade(id: "skipReset2", description: "Start every reset with 2 Dimension Boosts, automatically unlocking the 6th Antimatter Dimension", cost: 40, effect: {1})
    
    let skipReset3 = InfinityUpgrade(id: "skipReset3", description: "Start every reset with 3 Dimension Boosts, automatically unlocking the 7th Antimatter Dimension", cost: 80, effect: {1})
    
    let skipResetGalaxy = InfinityUpgrade(id: "skipResetGalaxy", description: "Start every reset with 4 Dimension Boosts, automatically unlocking the 8th Antimatter Dimension; and an Antimatter Galaxy", cost: 300, effect: {1})
    
//    let ipOffline = InfinityUpgrade(id: "ipOffline")
    
    var upgrades: [InfinityUpgrade] { [totalTimeMult, dim18Mult, dim27Mult, dim36Mult, dim45Mult, resetBoost, buy10Mult, galaxyBoost, thisInfinityTimeMult, unspentIPMult, dimboostMult, ipGen, skipReset1, skipReset2, skipReset3, skipResetGalaxy] }

    init(statistics: Statistics) {
        self.statistics = statistics
        self.totalTimeMult = InfinityUpgrade(id: "timeMult", description: "Antimatter Dimensions gain a multiplier based on time played", cost: 1, effect: {
            InfiniteDecimal(source: pow(abs(statistics.startDate.timeIntervalSinceNow) / 2, 0.15))
        })
        self.dim18Mult = InfinityUpgrade(id: "18Mult", description: "1st and 8th Antimatter Dimensions gain a multiplier based on Infinities", cost: 1)
        self.dim27Mult = InfinityUpgrade(id: "27Mult", description: "2nd and 7th Antimatter Dimensions gain a multiplier based on Infinities", cost: 1)
        self.dim36Mult = InfinityUpgrade(id: "36Mult", description: "3rd and 6th Antimatter Dimensions gain a multiplier based on Infinities", cost: 1)
        self.dim45Mult = InfinityUpgrade(id: "45Mult", description: "4th and 5th Antimatter Dimensions gain a multiplier based on Infinities", cost: 1)
        self.resetBoost = InfinityUpgrade(id: "resetBoost", description: "Decrease the number of Dimensions needed for Dimension Boosts and Antimatter Galaxies by 9", cost: 1, effect: {9})
        self.buy10Mult = InfinityUpgrade(id: "dimMult", description: "Increase the multiplier for buying 10 Antimatter Dimensions", cost: 1, effect: {
            1.1
        })
        self.galaxyBoost = InfinityUpgrade(id: "galaxyBoost", description: "All Galaxies are twice as strong", cost: 2, effect: {2})
        self.thisInfinityTimeMult = InfinityUpgrade(id: "timeMult2", description: "Antimatter Dimensions gain a multiplier based on time spent in current Infinity", cost: 3)
        self.unspentIPMult = InfinityUpgrade(id: "unspentBonus", description: "Multiplier to 1st Antimatter Dimension based on unspent Infinity Points", cost: 5)
        self.dimboostMult = InfinityUpgrade(id: "resetMult", description: "Increase Dimension Boost multiplier", cost: 7, effect: {2.5})
        self.ipGen = InfinityUpgrade(id: "passiveGen", description: "Passively generate Infinity Points 10 times slower than your fastest Infinity", cost: 10, effect: {1})
        
        self.dim18Mult.requirements = {self.totalTimeMult.bought}
        self.dim18Mult.effect = self.dimInfinityMult
        self.dim27Mult.requirements = {self.buy10Mult.bought}
        self.dim27Mult.effect = self.dimInfinityMult
        self.dim36Mult.requirements = {self.dim18Mult.bought}
        self.dim36Mult.effect = self.dimInfinityMult
        self.dim45Mult.requirements = {self.dim27Mult.bought}
        self.dim45Mult.effect = self.dimInfinityMult
        self.resetBoost.requirements = {self.dim36Mult.bought}
        self.galaxyBoost.requirements = {self.dim45Mult.bought}
        self.thisInfinityTimeMult.effect = {
            InfiniteDecimal(source: max(pow(abs(self.infinity?.infinityStartTime.timeIntervalSinceNow ?? 0) / 4, 0.25), 1))
        }
        self.unspentIPMult.effect = {
            self.infinity?.infinities.div(value: 2).pow(value: 1.5).add(value: 1) ?? 1
        }
        self.dimboostMult.requirements = {self.unspentIPMult.bought}
        self.ipGen.requirements = {self.dimboostMult.bought}
    }
}
