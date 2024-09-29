//
//  AchievementView.swift
//  ClickerGaem
//
//  Created by Justin Covell on 9/23/24.
//
import SwiftUI

struct AchievementView: View {
    var achievements: [Achievement] {
        Achievements.shared.achievements
    }
    var body: some View {
        List{
            ForEach(achievements) {achievement in
                HStack {
                    VStack(alignment: .leading) {
                        Text("\(achievement.name)")
                        Text("\(achievement.description)").font(.system(size: 10)).frame(alignment: .leading)
                    }
                    Spacer()
                    Label(achievement.unlocked ? "Unlocked" : "Locked", systemImage: achievement.unlocked ? "checkmark.circle.fill" : "lock.circle.fill").labelStyle(.iconOnly).foregroundStyle(achievement.unlocked ? .green : .red)
                }
            }
        }
    }
}

#Preview {
    AchievementView()
}
