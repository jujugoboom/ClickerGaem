//
//  Achievements.swift
//  ClickerGaem
//
//  Created by Justin Covell on 9/23/24.
//
import Foundation
import CoreData

class Achievement: Saveable, Identifiable {
    let id: Int
    let name: String
    let description: String
    let value: () -> Any
    let execute: (Any, Achievement) -> Void
    var storedState: StoredAchievementState?
    var unlockCallback: ((String) -> Void)? = nil
    private var initialized = false
    var unlocked = false {
        didSet {
            guard initialized && unlocked else {
                return
            }
            (unlockCallback ?? {_ in })(name)
        }
    }
    
    func load() {
        ClickerGaemData.shared.persistentContainer.viewContext.performAndWait {
            let req = StoredAchievementState.fetchRequest()
            req.fetchLimit = 1
            req.predicate = NSPredicate(format: "id == %d", self.id)
            guard let maybeStoredState = try? ClickerGaemData.shared.persistentContainer.viewContext.fetch(req).first else {
                storedState = StoredAchievementState(context: ClickerGaemData.shared.persistentContainer.viewContext)
                storedState?.id = Int64(id)
                storedState?.unlocked = unlocked
                return
            }
            storedState = maybeStoredState
        }
        unlocked = storedState?.unlocked ?? false
        return
    }
    
    func save(objectContext: NSManagedObjectContext, notification: NotificationCenter.Publisher.Output? = nil) {
        if storedState == nil {
            storedState = StoredAchievementState(context: objectContext)
        }
        storedState?.unlocked = unlocked
        try? objectContext.save()
    }
    
    func reset() {
        self.unlocked = false
    }
    
    init(id: Int, name: String, description: String, of value: @escaping @autoclosure () -> Any, execute: @escaping (Any, Achievement) -> Void) {
        self.id = id
        self.name = name
        self.description = description
        self.value = value
        self.execute = execute
        self.load()
        guard !unlocked else {
            // Already unlocked, no need to monitor
            return
        }
        // Should set unlocked initial value
        execute(value(), self)
        // Consider self fully initialized
        self.initialized = true
        // Start obsesrvation of provided value
        withContinousObservation(of: value(), execute: execute)
    }
    
    func withContinousObservation(of value: @escaping @autoclosure () -> Any, execute: @escaping (Any, Achievement) -> Void) {
        guard !self.unlocked else {
            return
        }
        withObservationTracking { [weak self] in
            execute(value(), self!)
        } onChange: {
            Task { [weak self] in
                self!.withContinousObservation(of: value(), execute: execute)
            }
        }
    }
}

@Observable
class Achievements {
    var newAchievementName = ""
    var unlockedNewAchievement = false
    
    let eleventh: Achievement
    let twelfth: Achievement
    let thirteenth: Achievement
    let fourteenth: Achievement
    let fifteenth: Achievement
    let sixteenth: Achievement
    let seventeenth: Achievement
    let eighteenth: Achievement
    
    var achievements: [Achievement] { [eleventh, twelfth, thirteenth, fourteenth, fifteenth, sixteenth, seventeenth, eighteenth] }
    
    var unlockedAchievements: [Achievement] {
        achievements.filter(\.unlocked)
    }
    
    func onUnlock(_ name: String) {
        self.newAchievementName = name
        self.unlockedNewAchievement = true
    }
    
    init(antimatter: Antimatter) {
        eleventh = Achievement(id: 11, name: "You gotta start somewhere", description: "Buy first antimatter dimension", of: antimatter.dimensions.dimensions[1]!.purchaseCount) { purchaseCount, achievement in
            if purchaseCount as! Int > 0 {
                achievement.unlocked = true
            }
        }
        twelfth = Achievement(id: 12, name: "100 antimatter is a lot", description: "Buy a 2nd Antimatter Dimension", of: antimatter.dimensions.dimensions[2]!.purchaseCount) { purchaseCount, achievement in
            if purchaseCount as! Int > 0 {
                achievement.unlocked = true
            }
        }
        thirteenth = Achievement(id: 13, name: "Half life 3 CONFIRMED", description: "Buy a 3rd Antimatter Dimension.", of: antimatter.dimensions.dimensions[3]!.purchaseCount) {purchaseCount, achievement in
            if purchaseCount as! Int > 0 {
                achievement.unlocked = true
            }
        }
        fourteenth = Achievement(id: 14, name: "L4D: Left 4 Dimensions", description: "Buy a 4th Antimatter Dimension.", of: antimatter.dimensions.dimensions[4]!.purchaseCount) {purchaseCount, achievement in
            if purchaseCount as! Int > 0 {
                achievement.unlocked = true
            }
        }
        fifteenth = Achievement(id: 15, name: "5 Dimension Antimatter Punch", description: "Buy a 5th Antimatter Dimension.", of: antimatter.dimensions.dimensions[5]!.purchaseCount) {purchaseCount, achievement in
            if purchaseCount as! Int > 0 {
                achievement.unlocked = true
            }
        }
        sixteenth = Achievement(id: 16, name: "We couldn't afford 9", description: "Buy a 6th Antimatter Dimension.", of: antimatter.dimensions.dimensions[6]!.purchaseCount) {purchaseCount, achievement in
            if purchaseCount as! Int > 0 {
                achievement.unlocked = true
            }
        }
        seventeenth = Achievement(id: 17, name: "Not a luck related achievement", description: "Buy a 7th Antimatter Dimension.", of: antimatter.dimensions.dimensions[7]!.purchaseCount) {purchaseCount, achievement in
            if purchaseCount as! Int > 0 {
                achievement.unlocked = true
            }
        }
        eighteenth = Achievement(id: 18, name: "90 degrees to infinity", description: "Buy a 8th Antimatter Dimension.", of: antimatter.dimensions.dimensions[8]!.purchaseCount) {purchaseCount, achievement in
            if purchaseCount as! Int > 0 {
                achievement.unlocked = true
            }
        }

        achievements.forEach({$0.unlockCallback = self.onUnlock})
        print("Achievements initialized")
    }
}
