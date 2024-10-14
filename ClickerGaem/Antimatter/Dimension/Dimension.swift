//
//  Dimension.swift
//  ClickerGaem
//
//  Created by Justin Covell on 9/15/24.
//

import Foundation
import OrderedCollections
import CoreData

/// Main dimension class. Setup expecting that there are a max of 8 dimensions, and will fail if set to a 9th tier
@Observable
class Dimension: Identifiable, Saveable {
    let antimatter: Antimatter
    let tierPrices: [Int: InfiniteDecimal] = [1: 10, 2: 100, 3: 10000, 4: 1e6, 5: 1e9, 6: 1e13, 7: 1e18, 8: 1e24]
    let basePriceIncreases: [Int: InfiniteDecimal] = [1: 1e3, 2: 1e4, 3: 1e5, 4: 1e6, 5: 1e8, 6: 1e10, 7: 1e12, 8: 1e15]
    
    var storedState: StoredDimensionState?
    let tier: Int
    var purchaseCount: Int {
        didSet {
            costIncreases = purchaseCount / 10
        }
    }
    var costIncreases: Int = 0
    var currCount: InfiniteDecimal
    var unlocked: Bool
    
    func load() {
        ClickerGaemData.shared.persistentContainer.viewContext.performAndWait {
            let req = StoredDimensionState.fetchRequest()
            req.fetchLimit = 1
            req.predicate = NSPredicate(format: "tier == %d", self.tier)
            guard let maybeStoredState = try? ClickerGaemData.shared.persistentContainer.viewContext.fetch(req).first else {
                self.storedState = StoredDimensionState(context: ClickerGaemData.shared.persistentContainer.viewContext)
                self.storedState!.tier = Int64(tier)
                self.storedState!.currCount = currCount
                self.storedState!.purchaseCount = Int64(purchaseCount)
                self.storedState!.unlocked = unlocked
                return
            }
            self.storedState = maybeStoredState
        }
        self.purchaseCount = Int(storedState!.purchaseCount)
        self.unlocked = storedState!.unlocked
        self.currCount = storedState!.currCount as! InfiniteDecimal
    }
    
    func save(objectContext: NSManagedObjectContext, notification: NotificationCenter.Publisher.Output? = nil) {
        if storedState == nil {
            storedState = StoredDimensionState(context: objectContext)
        }
        storedState!.tier = Int64(tier)
        storedState!.purchaseCount = Int64(purchaseCount)
        storedState!.currCount = currCount
        storedState!.unlocked = unlocked
        try? objectContext.save()
    }
    
    func reset(keepUnlocked: Bool = false) {
        self.purchaseCount = 0
        self.currCount = .zeroDecimal
        self.unlocked = keepUnlocked ? unlocked : tier <= 4
    }
    
    var timesBought: InfiniteDecimal {
        InfiniteDecimal(integerLiteral: purchaseCount / 10).floor()
    }
    
    var cost: InfiniteDecimal {
        let priceIncrease = basePriceIncreases[tier]?.pow(value: timesBought)
        return tierPrices[tier]?.mul(value: priceIncrease ?? InfiniteDecimal.nanDecimal) ?? InfiniteDecimal.nanDecimal
    }
    
    var boughtBefore10: Int {
        purchaseCount % 10
    }
    
    var dimensionBoostMultiplier: InfiniteDecimal {
        guard tier <= antimatter.dimensionBoosts else {
            return 1
        }
        return InfiniteDecimal(integerLiteral: 2).pow(value: InfiniteDecimal(integerLiteral: max(antimatter.dimensionBoosts - (tier - 1), 1)))
    }
    
    var multiplier: InfiniteDecimal {
        var val = InfiniteDecimal(source: 2).pow(value: timesBought).max(other: 1)
        val = val.mul(value: dimensionBoostMultiplier)
        if infinityMultiplier.bought {
            val = val.mul(value: (infinityMultiplier.effect ?? {1})())
        }
        if tier == 8 {
            val = val.mul(value: antimatter.dimensionSacrificeMul)
        }
        return val
    }
    
    var howManyCanBuy: InfiniteDecimal {
        guard cost.isFinite() else {
            return 0
        }
        let ratio = antimatter.antimatter.div(value: cost)
        return ratio.min(other: InfiniteDecimal(integerLiteral: 10 - boughtBefore10)).max(other: 0).floor()
    }
    
    var perSecond: InfiniteDecimal {
        currCount.mul(value: antimatter.ticksPerSecond).mul(value: multiplier)
    }
    
    var infinityMultiplier: InfinityUpgrade
    
    init(tier: Int, antimatter: Antimatter, infinityUpgrades: InfinityUpgrades) {
        self.antimatter = antimatter
        self.tier = tier
        self.purchaseCount = 0
        self.unlocked = tier <= 4
        self.currCount = .zeroDecimal
        infinityMultiplier = switch tier {
        case 1, 8:
            infinityUpgrades.dim18Mult
        case 2, 7:
            infinityUpgrades.dim27Mult
        case 3, 6:
            infinityUpgrades.dim36Mult
        case 4, 5:
            infinityUpgrades.dim45Mult
        default:
            fatalError("no other dimension multiplier for \(tier)")
        }
        self.load()
    }
}

class Dimensions: Saveable {
    let antimatter: Antimatter
    let infinity: Infinity
    let statistics: Statistics
    
    let dimensions: OrderedDictionary<Int, Dimension>
    
    var unlockedDimensions: [Dimension] {
        dimensions.values.filter() {dimension in
            dimension.unlocked
        }
    }
    
    var amPerSecond: InfiniteDecimal {
        guard dimensions.keys.contains(1) else {
            return 0
        }
        return dimensions[1]!.perSecond
    }
    
    init(antimatter: Antimatter, infinity: Infinity, statistics: Statistics, infinityUpgrades: InfinityUpgrades) {
        self.antimatter = antimatter
        self.infinity = infinity
        self.statistics = statistics
        self.dimensions = (1...8).reduce(into: [:], { pv, cv in
            pv[cv] = Dimension(tier: cv, antimatter: antimatter, infinityUpgrades: infinityUpgrades)
        })
    }
    
    func canBuyDimension(_ tier: Int) -> Bool {
        if let dimension = dimensions[tier] {
            return dimension.unlocked && dimension.howManyCanBuy.gt(other: 0) && (tier > 1 ? dimensions[tier - 1]?.purchaseCount ?? 0 > 0 : true)
        }
        return false
    }
    
    @MainActor
    func buyDimension(_ tier: Int, count: InfiniteDecimal? = nil) {
        if let dimension = dimensions[tier] {
            let toBuy = count == nil ? dimension.howManyCanBuy : count!
            let totalCost = dimension.cost.mul(value: toBuy)
            guard antimatter.antimatter.gte(other: totalCost) else {
                return
            }
            guard antimatter.sub(amount: totalCost) else {
                // We actually don't have enough some how
                // Probably because this isn't @MainActor
                return
            }
            let intCount = toBuy.toInt()
            dimension.purchaseCount += intCount
            dimension.currCount = dimension.currCount.add(value: toBuy)
        }
    }
    
    @MainActor
    func tick(diff: TimeInterval) {
        unlockedDimensions.forEach({
            guard $0.purchaseCount > 0 else {
                return
            }
            guard !infinity.infinityBroken && !antimatter.antimatter.gte(other: Decimals.infinity) else {
                return
            }
            if $0.tier == 1 {
                let perSecond = $0.perSecond
                if perSecond.gt(other: statistics.bestAMs) {
                    statistics.bestAMs = perSecond
                }
                let generatedAntimatter = perSecond.mul(value: InfiniteDecimal(source: diff))
                antimatter.add(amount: generatedAntimatter)
                statistics.addAntimatter(amount: generatedAntimatter, diff: diff)
            } else {
                // Get dimension the tier below this one
                let lowerDimension = dimensions[$0.tier - 1]!
                lowerDimension.currCount = lowerDimension.currCount.add(value: $0.perSecond.mul(value: InfiniteDecimal(source: diff / 10)))
            }
        })
    }
    
    func save(objectContext: NSManagedObjectContext, notification: NotificationCenter.Publisher.Output?) {
        dimensions.values.forEach({$0.save(objectContext: objectContext, notification: notification)})
    }
    
    func load() {
        return
    }
}


extension Dimension: Comparable {
    static func == (lhs: Dimension, rhs: Dimension) -> Bool {
        lhs.tier == rhs.tier
    }
    
    static func < (lhs: Dimension, rhs: Dimension) -> Bool {
        return lhs.tier < rhs.tier
    }
}
