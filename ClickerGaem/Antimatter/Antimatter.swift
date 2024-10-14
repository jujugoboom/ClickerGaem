//
//  Antimatter.swift
//  ClickerGaem
//
//  Created by Justin Covell on 9/24/24.
//
import Foundation
import CoreData

@Observable
class Antimatter {
//    let infinity: Infinity
    let statistics: Statistics
//    let dimensions: Dimensions
    
    var storedState: StoredAntimatterState?
    public private(set) var antimatter: InfiniteDecimal = 10
    var tickSpeedUpgrades: InfiniteDecimal = 0
    var dimensionBoosts = 0
    var amGalaxies = 0
    var sacrificedDimensions: InfiniteDecimal = 0
    var dimensionSacrificeMul: InfiniteDecimal {
        Antimatter.dimensionSacrificeMultiplier(sacrificed: sacrificedDimensions)
    }
    var totalDimensionBoost: InfiniteDecimal {
        (2 as InfiniteDecimal).pow(value: InfiniteDecimal(integerLiteral: dimensionBoosts))
    }
    var tickspeedMultiplier: InfiniteDecimal {
        guard amGalaxies > 3 else {
            var baseMultiplier = 1 / 1.1245;
            if amGalaxies == 1 { baseMultiplier = 1 / 1.11888888 }
            if amGalaxies == 2 { baseMultiplier = 1 / 1.11267177 }
            let perGalaxy = 0.02
            return InfiniteDecimal(source: 0.01).max(other: InfiniteDecimal(source: baseMultiplier - (Double(amGalaxies) * perGalaxy)))
        }
        let baseMultiplier = 0.8
        let galaxies = amGalaxies - 2
        let perGalaxy = InfiniteDecimal(source: 0.965)
        return perGalaxy.pow(value: InfiniteDecimal(integerLiteral: galaxies - 2)).mul(value: InfiniteDecimal(source: baseMultiplier))
    }
    var ticksPerSecond: InfiniteDecimal {
        InfiniteDecimal(source: 1e3).div(value: InfiniteDecimal(source: 1e3).mul(value: tickspeedMultiplier.pow(value: tickSpeedUpgrades)))
    }
    
    var tickspeedUpgradeCost: InfiniteDecimal {
        InfiniteDecimal().pow10(value: tickSpeedUpgrades.add(value: 3).toDouble())
    }
    
    func load() {
        ClickerGaemData.shared.persistentContainer.viewContext.performAndWait {
            let req = StoredAntimatterState.fetchRequest()
            req.fetchLimit = 1
            guard let maybeStoredState = try? ClickerGaemData.shared.persistentContainer.viewContext.fetch(req).first else {
                self.storedState = StoredAntimatterState(context: ClickerGaemData.shared.persistentContainer.viewContext)
                self.storedState?.antimatter = antimatter
                self.storedState?.tickSpeedUpgrades = tickSpeedUpgrades
                self.storedState?.sacrificedDimensions = sacrificedDimensions
                self.storedState?.dimensionBoosts = Int64(dimensionBoosts)
                self.storedState?.galaxies = Int64(amGalaxies)
                return
            }
            self.storedState = maybeStoredState
        }
        self.antimatter = storedState!.antimatter as! InfiniteDecimal
        self.tickSpeedUpgrades = storedState!.tickSpeedUpgrades as! InfiniteDecimal
        self.sacrificedDimensions = storedState!.sacrificedDimensions as! InfiniteDecimal
        self.dimensionBoosts = Int(storedState!.dimensionBoosts)
        self.amGalaxies = Int(storedState!.galaxies)
    }
    
    func save(objectContext: NSManagedObjectContext, notification: NotificationCenter.Publisher.Output? = nil) {
        if storedState == nil {
            storedState = StoredAntimatterState(context: objectContext)
        }
        self.storedState!.antimatter = antimatter
        self.storedState!.tickSpeedUpgrades = tickSpeedUpgrades
        self.storedState!.sacrificedDimensions = sacrificedDimensions
        self.storedState!.dimensionBoosts = Int64(dimensionBoosts)
        self.storedState!.galaxies = Int64(amGalaxies)
        try? objectContext.save()
    }
    
    func reset() {
        self.antimatter = 10
        self.tickSpeedUpgrades = 0
        self.sacrificedDimensions = 0
        self.dimensionBoosts = 0
        self.amGalaxies = 0
        self.load()
    }
    
    
    init(infinity: Infinity, statistics: Statistics) {
//        self.infinity = infinity
        self.statistics = statistics
//        self.dimensions = Dimensions(infinityUpgrades: infinity.infinityUpgrades)
        self.load()
    }
    
    static func dimensionSacrificeMultiplier(sacrificed: InfiniteDecimal) -> InfiniteDecimal {
        InfiniteDecimal(source: sacrificed.log10() / 10).max(other: 1).pow(value: 2)
    }
    
    
    @MainActor
    func add(amount: InfiniteDecimal) {
        antimatter = antimatter.add(value: amount).min(other: Decimals.infinity)
    }
    
    @MainActor
    func sub(amount: InfiniteDecimal) -> Bool {
        guard antimatter.gte(other: amount) else {
            return false
        }
        antimatter = antimatter.sub(value: amount)
        return true
    }
    
    @MainActor
    func set(amount: InfiniteDecimal) {
        antimatter = amount
    }
    
//    func tick(diff: TimeInterval) {
//        dimensions.unlockedDimensions.forEach({
//            guard $0.purchaseCount > 0 else {
//                return
//            }
//            guard !infinity.infinityBroken && !antimatter.gte(other: Decimals.infinity) else {
//                return
//            }
//            if $0.tier == 1 {
//                let perSecond = $0.perSecond(antimatter: self)
//                if perSecond.gt(other: statistics.bestAMs) {
//                    statistics.bestAMs = perSecond
//                }
//                let generatedAntimatter = perSecond.mul(value: InfiniteDecimal(source: diff))
//                add(amount: generatedAntimatter)
//                statistics.addAntimatter(amount: generatedAntimatter, diff: diff)
//            } else {
//                // Get dimension the tier below this one
//                let lowerDimension = dimensions.dimensions[$0.tier - 1]!
//                lowerDimension.currCount = lowerDimension.currCount.add(value: $0.perSecond(antimatter: self).mul(value: InfiniteDecimal(source: diff / 10)))
//            }
//        })
//    }
}
