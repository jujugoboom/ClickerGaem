//
//  AutobuyerView.swift
//  ClickerGaem
//
//  Created by Justin Covell on 9/21/24.
//
import SwiftUI

struct AMAutobuyerView: View {
    var autobuyers: [AMDimensionAutobuyer] {
        Autobuyers.shared.dimensionAutobuyers
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
    Statistics.shared.totalAntimatter = InfiniteDecimal(mantissa: 1, exponent: 200)
    return AMAutobuyerView()
}
