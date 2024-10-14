//
//  AMDimensionAutobuyer.swift
//  ClickerGaem
//
//  Created by Justin Covell on 9/21/24.
//
import Foundation
import CoreData

@Observable
class AMDimensionAutobuyer: BuyableAutobuyer {
    var antimatter: Antimatter
    var statistics: Statistics
    var dimensions: Dimensions
    var purchased: Bool = false
    var id: String
    var enabled: Bool = false
    var unlocked: Bool = true
    var autobuyCount: Int = 0
    var storedState: StoredAutobuyerState?
    
    var type: AutobuyerType = .amdimension
    var tier: Int
    var cost: InfiniteDecimal {
        Decimals.e10.pow(value: InfiniteDecimal(integerLiteral: tier - 1)).mul(value: Decimals.e40);
    }
    var purchaseableCount: InfiniteDecimal {
        dimensions.dimensions[tier]?.howManyCanBuy ?? InfiniteDecimal.zeroDecimal
    }
    var buyRate: Double {
        [0, 500, 600, 700, 800, 900, 1000, 1100, 1200][tier] / 1000
    }
    
    var canBuy: Bool {
        return statistics.totalAntimatter.gte(other: cost)
    }
    
    var elapsedSinceBuy: Double = 0
    
    init(antimatter: Antimatter, statistics: Statistics, dimensions: Dimensions, tier: Int, purchaseAmount: Int = 10) {
        self.antimatter = antimatter
        self.statistics = statistics
        self.dimensions = dimensions
        self.tier = tier
        self.type = .amdimension
        self.id = "dimension-autobuyer-\(tier)"
        self.load()
        if self.autobuyCount == 0 {
            self.autobuyCount = purchaseAmount
        }
    }
    
    @MainActor
    func tick(diff: TimeInterval) {
        guard enabled && unlocked else {
            return
        }
        // Update our total diff time
        elapsedSinceBuy += diff
        guard elapsedSinceBuy > buyRate else {
            return
        }
        // Reset our timer
        elapsedSinceBuy = 0
        // Check we can buy how many we want
        guard purchaseableCount.gte(other: InfiniteDecimal(integerLiteral: autobuyCount)) else {
            return
        }
        dimensions.buyDimension(tier, count: InfiniteDecimal(integerLiteral: autobuyCount))
    }
    
    
    func load() {
        let req = StoredAutobuyerState.fetchRequest()
        req.fetchLimit = 1
        req.predicate = NSPredicate(format: "id == %@", id)
        guard let maybeStoredState = try? ClickerGaemData.shared.persistentContainer.viewContext.fetch(req).first else {
            storedState = StoredAutobuyerState(context: ClickerGaemData.shared.persistentContainer.viewContext)
            storedState?.id = id
            storedState?.unlocked = unlocked
            storedState?.enabled = enabled
            storedState?.autobuyCount = Int64(autobuyCount)
            return
        }
        storedState = maybeStoredState
        unlocked = storedState!.unlocked
        enabled = storedState!.enabled
        autobuyCount = Int(storedState!.autobuyCount)
        purchased = storedState!.purchased
    }
    
    func save(objectContext: NSManagedObjectContext, notification: NotificationCenter.Publisher.Output? = nil) {
        if storedState == nil {
            storedState = StoredAutobuyerState(context: objectContext)
        }
        storedState?.id = id
        storedState?.unlocked = unlocked
        storedState?.enabled = enabled
        storedState?.autobuyCount = Int64(autobuyCount)
        storedState?.purchased = purchased
        try? objectContext.save()
    }
}
