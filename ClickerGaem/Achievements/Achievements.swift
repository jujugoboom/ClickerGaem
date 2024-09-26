//
//  Achievements.swift
//  ClickerGaem
//
//  Created by Justin Covell on 9/23/24.
//
import Foundation
import CoreData

@Observable
class Achievement: Saveable, Identifiable {
    let id: Int
    let name: String
    let description: String
    let value: () -> Any
    let execute: (Any, Achievement) -> Void
    var storedState: StoredAchievementState?
    private var initialized = false
    var unlocked = false {
        didSet {
            guard initialized && unlocked else {
                return
            }
            Achievements.shared.newAchievementName = name
            Achievements.shared.unlockedNewAchievement = true
        }
    }
    
    func load() {
        let req = StoredAchievementState.fetchRequest()
        req.fetchLimit = 1
        req.predicate = NSPredicate(format: "id == %d", self.id)
        let context = ClickerGaemData.shared.persistentContainer.newBackgroundContext()
        guard let maybeStoredState = try? context.fetch(req).first else {
            storedState = StoredAchievementState(context: ClickerGaemData.shared.persistentContainer.viewContext)
            storedState?.unlocked = unlocked
            return
        }
        storedState = maybeStoredState
        unlocked = storedState?.unlocked ?? false
        return
    }
    
    func save(objectContext: NSManagedObjectContext) {
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
        withObservationTracking {
            execute(value(), self)
        } onChange: {
            Task { @MainActor in
                self.withContinousObservation(of: value(), execute: execute)
            }
        }
    }
}

@Observable
class Achievements: Resettable {
    private static var _shared: Achievements?
    static var shared: Achievements {
        if _shared == nil { _shared = Achievements() }
        return _shared!
    }
    var unlockedNewAchievement = false
    var newAchievementName = ""
    let eleventh = Achievement(id: 11, name: "You gotta start somewhere", description: "Buy first antimatter dimension", of: Dimensions.shared.dimensions[1]!.state.purchaseCount) { purchaseCount, achievement in
        if purchaseCount as! Int > 0 {
            achievement.unlocked = true
        }
    }
    
    let twelfth = Achievement(id: 12, name: "100 antimatter is a lot", description: "Buy a 2nd Antimatter Dimension", of: Dimensions.shared.dimensions[2]!.state.purchaseCount) { purchaseCount, achievement in
        if purchaseCount as! Int > 0 {
            achievement.unlocked = true
        }
    }
    
    let thirteenth = Achievement(id: 13, name: "Half life 3 CONFIRMED", description: "Buy a 3rd Antimatter Dimension.", of: Dimensions.shared.dimensions[3]!.state.purchaseCount) {purchaseCount, achievement in
        if purchaseCount as! Int > 0 {
            achievement.unlocked = true
        }
    }
    
    let fourteenth = Achievement(id: 14, name: "L4D: Left 4 Dimensions", description: "Buy a 4th Antimatter Dimension.", of: Dimensions.shared.dimensions[4]!.state.purchaseCount) {purchaseCount, achievement in
        if purchaseCount as! Int > 0 {
            achievement.unlocked = true
        }
    }
    
    let fifteenth = Achievement(id: 15, name: "5 Dimension Antimatter Punch", description: "Buy a 5th Antimatter Dimension.", of: Dimensions.shared.dimensions[5]!.state.purchaseCount) {purchaseCount, achievement in
        if purchaseCount as! Int > 0 {
            achievement.unlocked = true
        }
    }
    
    let sixteenth = Achievement(id: 16, name: "We couldn't afford 9", description: "Buy a 6th Antimatter Dimension.", of: Dimensions.shared.dimensions[6]!.state.purchaseCount) {purchaseCount, achievement in
        if purchaseCount as! Int > 0 {
            achievement.unlocked = true
        }
    }
    
    let seventeenth = Achievement(id: 17, name: "Not a luck related achievement", description: "Buy a 7th Antimatter Dimension.", of: Dimensions.shared.dimensions[7]!.state.purchaseCount) {purchaseCount, achievement in
        if purchaseCount as! Int > 0 {
            achievement.unlocked = true
        }
    }
    
    let eighteenth = Achievement(id: 18, name: "90 degrees to infinity", description: "Buy a 8th Antimatter Dimension.", of: Dimensions.shared.dimensions[8]!.state.purchaseCount) {purchaseCount, achievement in
        if purchaseCount as! Int > 0 {
            achievement.unlocked = true
        }
    }
    
    var achievements: [Achievement] { [eleventh, twelfth, thirteenth, fourteenth, fifteenth, sixteenth, seventeenth, eighteenth] }
    
    var unlockedAchievements: [Achievement] {
        achievements.filter(\.unlocked)
    }
    
    init() {
        print("Achievements initialized")
    }
    
    static func reset() {
        _shared?.achievements.forEach({$0.reset()})
        _shared?.achievements.forEach({$0.load()})
    }
}
