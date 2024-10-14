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
class Dimension: Identifiable {
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
    
    var infinityMultiplier: InfinityUpgrade
    
    init(tier: Int, infinityUpgrades: InfinityUpgrades) {
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
    
    func dimensionBoostMultiplier(antimatter: Antimatter) -> InfiniteDecimal {
        guard tier <= antimatter.dimensionBoosts else {
            return 1
        }
        return InfiniteDecimal(integerLiteral: 2).pow(value: InfiniteDecimal(integerLiteral: max(antimatter.dimensionBoosts - (tier - 1), 1)))
    }
    
    func multiplier(antimatter: Antimatter) -> InfiniteDecimal {
        var val = InfiniteDecimal(source: 2).pow(value: timesBought).max(other: 1)
        val = val.mul(value: dimensionBoostMultiplier(antimatter: antimatter))
        if infinityMultiplier.bought {
            val = val.mul(value: (infinityMultiplier.effect ?? {1})())
        }
        if tier == 8 {
            val = val.mul(value: antimatter.dimensionSacrificeMul)
        }
        return val
    }
    
    func howManyCanBuy(antimatter: Antimatter) -> InfiniteDecimal {
        guard cost.isFinite() else {
            return 0
        }
        let ratio = antimatter.antimatter.div(value: cost)
        return ratio.min(other: InfiniteDecimal(integerLiteral: 10 - boughtBefore10)).max(other: 0).floor()
    }
    
    func perSecond(antimatter: Antimatter) -> InfiniteDecimal {
        currCount.mul(value: antimatter.ticksPerSecond).mul(value: multiplier(antimatter: antimatter))
    }
}

class Dimensions {
    
    let dimensions: OrderedDictionary<Int, Dimension>
    
    var unlockedDimensions: [Dimension] {
        dimensions.values.filter() {dimension in
            dimension.unlocked
        }
    }
    
    init(infinityUpgrades: InfinityUpgrades) {
        self.dimensions = [1: Dimension(tier: 1, infinityUpgrades: infinityUpgrades), 2: Dimension(tier: 2, infinityUpgrades: infinityUpgrades), 3: Dimension(tier: 3, infinityUpgrades: infinityUpgrades), 4: Dimension(tier: 4, infinityUpgrades: infinityUpgrades), 5: Dimension(tier: 5, infinityUpgrades: infinityUpgrades), 6: Dimension(tier: 6, infinityUpgrades: infinityUpgrades), 7: Dimension(tier: 7, infinityUpgrades: infinityUpgrades), 8: Dimension(tier: 8, infinityUpgrades: infinityUpgrades)]
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
