//
//  StatisticsView.swift
//  ClickerGaem
//
//  Created by Justin Covell on 10/8/24.
//
import SwiftUI

struct StatisticsView: View {
    var body: some View {
        VStack {
            Text("Total Antimatter: \(Statistics.shared.totalAntimatter)")
            Text("Best AM/s: \(Statistics.shared.bestAMs)")
            if (Statistics.shared.firstInfinity) {
                Text("Total infinities: \(Statistics.shared.totalInfinities)")
                Text("Best infinities/s: \(Statistics.shared.bestInfinitiesS)")
            }
        }
    }
}
