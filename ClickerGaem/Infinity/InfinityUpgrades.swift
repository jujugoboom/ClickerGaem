//
//  InfinityUpgrades.swift
//  ClickerGaem
//
//  Created by Justin Covell on 10/1/24.
//
import Foundation
import CoreData

class InfinityUpgrade: Saveable, Identifiable {
    var storedInfinityUpgradeState: StoredInfinityUpgrade?
    var bought = false
    var id: String;
    var description: String;
    var cost: InfiniteDecimal;
    var effect: () -> InfiniteDecimal
    var requirements: (() -> Bool)?
    
    var canBuy: Bool {
        requirements?() ?? true && !bought && Infinity.shared.state.infinities.gte(other: cost)
    }
    
    init(bought: Bool = false, id: String, description: String, cost: InfiniteDecimal, requirements: (() -> Bool)? = nil, effect: @escaping () -> InfiniteDecimal) {
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
    
    func buy() {
        guard canBuy else {
            return
        }
        Infinity.shared.state.infinities = Infinity.shared.state.infinities.sub(value: cost)
        bought = true
    }
}

class InfinityUpgrades: Resettable {
    static var shared = InfinityUpgrades()
    
    let totalTimeMult = InfinityUpgrade(id: "timeMult", description: "Antimatter Dimensions gain a multiplier based on time played", cost: 1) {
        InfiniteDecimal(source: pow(abs(Statistics.shared.startDate.timeIntervalSinceNow) / 2, 0.15))
    }
    
    static func dimInfinityMult() -> InfiniteDecimal {
        Statistics.shared.totalInfinities.mul(value: 0.2).add(value: 1)
    }
    
    let dim18Mult = InfinityUpgrade(id: "18Mult", description: "1st and 8th Antimatter Dimensions gain a multiplier based on Infinities", cost: 1, requirements: {shared.totalTimeMult.bought}) {
        InfinityUpgrades.dimInfinityMult()
    }
    
    let dim27Mult = InfinityUpgrade(id: "27Mult", description: "2nd and 7th Antimatter Dimensions gain a multiplier based on Infinities", cost: 1, requirements: {shared.buy10Mult.bought}) {
        InfinityUpgrades.dimInfinityMult()
    }
    
    let dim36Mult = InfinityUpgrade(id: "36Mult", description: "3rd and 6th Antimatter Dimensions gain a multiplier based on Infinities", cost: 1, requirements: {shared.dim18Mult.bought}) {
        InfinityUpgrades.dimInfinityMult()
    }
    
    let dim45Mult = InfinityUpgrade(id: "45Mult", description: "4th and 5th Antimatter Dimensions gain a multiplier based on Infinities", cost: 1, requirements: {shared.dim27Mult.bought}) {
        InfinityUpgrades.dimInfinityMult()
    }
    
    let resetBoost = InfinityUpgrade(id: "resetBoost", description: "Decrease the number of Dimensions needed for Dimension Boosts and Antimatter Galaxies by 9", cost: 1, requirements: {shared.dim36Mult.bought}) {
        9
    }
    
    let buy10Mult = InfinityUpgrade(id: "dimMult", description: "Increase the multiplier for buying 10 Antimatter Dimensions", cost: 1) {
        1.1
    }
    
    let galaxyBoost = InfinityUpgrade(id: "galaxyBoost", description: "All Galaxies are twice as strong", cost: 2, requirements: {shared.dim45Mult.bought}) {
        2
    }
    
    let thisInfinityTimeMult = InfinityUpgrade(id: "timeMult2", description: "Antimatter Dimensions gain a multiplier based on time spent in current Infinity", cost: 3) {
        InfiniteDecimal(source: max(pow(abs(Infinity.shared.state.infinityStartTime.timeIntervalSinceNow) / 4, 0.25), 1))
    }
    
    let unspentIPMult = InfinityUpgrade(id: "unspentBonus", description: "Multiplier to 1st Antimatter Dimension based on unspent Infinity Points", cost: 5) {
        Infinity.shared.state.infinities.div(value: 2).pow(value: 1.5).add(value: 1)
    }
    
    let dimboostMult = InfinityUpgrade(id: "resetMult", description: "Increase Dimension Boost multiplier", cost: 7, requirements: {shared.unspentIPMult.bought}) {
        2.5
    }
    
    let ipGen = InfinityUpgrade(id: "passiveGen", description: "Passively generate Infinity Points 10 times slower than your fastest Infinity", cost: 10, requirements: {shared.dimboostMult.bought}) {1}
    
    let skipReset1 = InfinityUpgrade(id: "skipReset1", description: "Start every reset with 1 Dimension Boost, automatically unlocking the 5th Antimatter Dimension", cost: 20) {1}
    
    let skipReset2 = InfinityUpgrade(id: "skipReset2", description: "Start every reset with 2 Dimension Boosts, automatically unlocking the 6th Antimatter Dimension", cost: 40) {1}
    
    let skipReset3 = InfinityUpgrade(id: "skipReset3", description: "Start every reset with 3 Dimension Boosts, automatically unlocking the 7th Antimatter Dimension", cost: 80) {1}
    
    let skipResetGalaxy = InfinityUpgrade(id: "skipResetGalaxy", description: "Start every reset with 4 Dimension Boosts, automatically unlocking the 8th Antimatter Dimension; and an Antimatter Galaxy", cost: 300) {1}
    
//    let ipOffline = InfinityUpgrade(id: "ipOffline")
    
    var upgrades: [InfinityUpgrade] { [totalTimeMult, dim18Mult, dim27Mult, dim36Mult, dim45Mult, resetBoost, buy10Mult, galaxyBoost, thisInfinityTimeMult, unspentIPMult, dimboostMult, ipGen, skipReset1, skipReset2, skipReset3, skipResetGalaxy] }
    
    static func reset() {
        shared.upgrades.forEach({$0.bought = false})
    }
}
