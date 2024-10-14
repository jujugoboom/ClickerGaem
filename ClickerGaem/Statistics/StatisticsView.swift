//
//  StatisticsView.swift
//  ClickerGaem
//
//  Created by Justin Covell on 10/8/24.
//
import SwiftUI

struct StatisticsView: View {
    @Environment(GameInstance.self) var gameInstance
    var statistics: Statistics {
        gameInstance.statistics
    }
    var body: some View {
        VStack {
            Text("Total Antimatter: \(statistics.totalAntimatter)")
            Text("Best AM/s: \(statistics.bestAMs)")
            if (statistics.firstInfinity) {
                Text("Total infinities: \(statistics.totalInfinities)")
                Text("Best infinities/s: \(statistics.bestInfinitiesS)")
            }
        }
    }
}
