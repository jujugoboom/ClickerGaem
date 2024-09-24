//
//  Achievements.swift
//  ClickerGaem
//
//  Created by Justin Covell on 9/23/24.
//
import Foundation

@Observable
class Achievement<T>: Identifiable {
    let id: Int
    let name: String
    let description: String
    var unlocked: Bool {
        didSet {
            Achievements.shared.newAchievementName = name
            Achievements.shared.unlockedNewAchievement = true
            print("Unlocked \(name)")
        }
    }
    
    init(id: Int, name: String, description: String, unlocked: Bool, of value: @escaping @autoclosure () -> T, execute: @escaping (T, Achievement) -> Void) {
        self.id = id
        self.name = name
        self.description = description
        self.unlocked = unlocked
        withContinousObservation(of: value(), execute: execute)
    }
    
    func withContinousObservation(of value: @escaping @autoclosure () -> T, execute: @escaping (T, Achievement) -> Void) {
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
class Achievements {
    static var shared = Achievements()
    var unlockedNewAchievement = false
    var newAchievementName = ""
    static let eleventh = Achievement(id: 11, name: "You gotta start somewhere", description: "Buy first antimatter dimension", unlocked: false, of: GameState.shared.dimensions[1]!.state.purchaseCount) { purchaseCount, achievement in
        if purchaseCount > 0 {
            achievement.unlocked = true
        }
    }
    
    static let twelfth = Achievement(id: 12, name: "100 antimatter is a lot", description: "Buy a 2nd Antimatter Dimension", unlocked: false, of: GameState.shared.dimensions[2]!.state.purchaseCount) { purchaseCount, achievement in
        if purchaseCount > 0 {
            achievement.unlocked = true
        }
    }
    
    static let thirteenth = Achievement(id: 13, name: "Half life 3 CONFIRMED", description: "Buy a 3rd Antimatter Dimension.", unlocked: false, of: GameState.shared.dimensions[3]!.state.purchaseCount) {purchaseCount, achievement in
        if purchaseCount > 0 {
            achievement.unlocked = true
        }
    }
    
    static let fourteenth = Achievement(id: 14, name: "L4D: Left 4 Dimensions", description: "Buy a 4th Antimatter Dimension.", unlocked: false, of: GameState.shared.dimensions[4]!.state.purchaseCount) {purchaseCount, achievement in
        if purchaseCount > 0 {
            achievement.unlocked = true
        }
    }
    
    static let fifteenth = Achievement(id: 15, name: "5 Dimension Antimatter Punch", description: "Buy a 5th Antimatter Dimension.", unlocked: false, of: GameState.shared.dimensions[5]!.state.purchaseCount) {purchaseCount, achievement in
        if purchaseCount > 0 {
            achievement.unlocked = true
        }
    }
    
    static let sixteenth = Achievement(id: 16, name: "We couldn't afford 9", description: "Buy a 6th Antimatter Dimension.", unlocked: false, of: GameState.shared.dimensions[6]!.state.purchaseCount) {purchaseCount, achievement in
        if purchaseCount > 0 {
            achievement.unlocked = true
        }
    }
    
    static let seventeenth = Achievement(id: 17, name: "Not a luck related achievement", description: "Buy a 7th Antimatter Dimension.", unlocked: false, of: GameState.shared.dimensions[7]!.state.purchaseCount) {purchaseCount, achievement in
        if purchaseCount > 0 {
            achievement.unlocked = true
        }
    }
    
    static let eighteenth = Achievement(id: 18, name: "90 degrees to infinity", description: "Buy a 8th Antimatter Dimension.", unlocked: false, of: GameState.shared.dimensions[8]!.state.purchaseCount) {purchaseCount, achievement in
        if purchaseCount > 0 {
            achievement.unlocked = true
        }
    }
    
    let achievements = [Achievements.eleventh, Achievements.twelfth, Achievements.thirteenth, Achievements.fourteenth, Achievements.fifteenth, Achievements.sixteenth, Achievements.seventeenth, Achievements.eighteenth]
    
    var unlockedAchievements: [Achievement<Any>] {
        achievements.filter(\.unlocked) as! [Achievement<Any>]
    }
}
