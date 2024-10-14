//
//  AutobuyerView.swift
//  ClickerGaem
//
//  Created by Justin Covell on 9/21/24.
//
import SwiftUI

struct AMAutobuyerView: View {
    @Environment(GameInstance.self) var gameInstance
    var autobuyers: [AMDimensionAutobuyer] {
        gameInstance.autobuyers.dimensionAutobuyers
    }
    
    let columns: [GridItem] = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns) {
                ForEach(autobuyers) {autobuyer in
                    AMDimensionAutobuyerView(autobuyer: autobuyer)
                }.padding()
            }
        }
    }
}

#Preview {
    ClickerGaemData.shared.persistentContainer = ClickerGaemData.preview
    let gameInstance = GameInstance()
    gameInstance.statistics.totalAntimatter = InfiniteDecimal(mantissa: 1, exponent: 200)
    return AMAutobuyerView().environment(gameInstance)
}
