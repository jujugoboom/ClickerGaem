//
//  Antimatter.swift
//  ClickerGaem
//
//  Created by Justin Covell on 9/24/24.
//
import Foundation
import CoreData

@Observable
class AntimatterState: Saveable {
    var storedState: StoredAntimatterState?
    var antimatter: InfiniteDecimal = 10
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
    var ticksPerSecond: InfiniteDecimal {
        InfiniteDecimal(source: 1).add(value: tickSpeedUpgrades.mul(value: InfiniteDecimal(source: 1.125 * max(Double(amGalaxies) * 1.4, 1))))
    }
    var amPerSecond: InfiniteDecimal {
        guard Dimensions.shared.dimensions.keys.contains(1) else {
            return 0
        }
        return Dimensions.shared.dimensions[1]!.perSecond
    }
    
    var tickspeedUpgradeCost: InfiniteDecimal {
        InfiniteDecimal().pow10(value: tickSpeedUpgrades.add(value: 3).toDouble())
    }
    
    func load() {
        let req = StoredAntimatterState.fetchRequest()
        req.fetchLimit = 1
        let context = ClickerGaemData.shared.persistentContainer.newBackgroundContext()
        guard let maybeStoredState = try? context.fetch(req).first else {
            self.storedState = StoredAntimatterState(context: ClickerGaemData.shared.persistentContainer.viewContext)
            self.storedState?.antimatter = antimatter
            self.storedState?.tickSpeedUpgrades = tickSpeedUpgrades
            self.storedState?.sacrificedDimensions = sacrificedDimensions
            self.storedState?.dimensionBoosts = Int64(dimensionBoosts)
            self.storedState?.galaxies = Int64(amGalaxies)
            return
        }
        self.storedState = maybeStoredState
        self.antimatter = storedState!.antimatter as! InfiniteDecimal
        self.tickSpeedUpgrades = storedState!.tickSpeedUpgrades as! InfiniteDecimal
        self.sacrificedDimensions = storedState!.sacrificedDimensions as! InfiniteDecimal
        self.dimensionBoosts = Int(storedState!.dimensionBoosts)
        self.amGalaxies = Int(storedState!.galaxies)
    }
    
    func save(objectContext: NSManagedObjectContext) {
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
    }
    
    init() {
        self.load()
    }
}
