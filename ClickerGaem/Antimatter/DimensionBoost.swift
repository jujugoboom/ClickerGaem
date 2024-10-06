//
//  DimensionSacrifice.swift
//  ClickerGaem
//
//  Created by Justin Covell on 9/19/24.
//

import Foundation
import SwiftUI

struct DimensionBoostView: View {
    var strCost: String {
        guard Antimatter.shared.state.dimensionBoosts >= 4 else {
            return "20 \(Antimatter.shared.state.dimensionBoosts + 4)th dimensions"
        }
        return "\(Antimatter.shared.dimensionBoostCost.keys.first!) 8th dimensions"
    }
    var body: some View {
        HStack{
            Text("\(Antimatter.shared.state.dimensionBoosts) dimension boosts")
            Button(action: Antimatter.shared.buyDimensionBoost) {
                Text(strCost).contentShape(.rect)
            }.disabled(!Antimatter.shared.canBuyDimensionBoost)
        }
    }}
