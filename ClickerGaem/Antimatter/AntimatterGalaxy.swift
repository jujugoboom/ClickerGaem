//
//  AntimatterGalaxy.swift
//  ClickerGaem
//
//  Created by Justin Covell on 9/19/24.
//

import Foundation
import SwiftUI

struct AntimatterGalaxy: View {
    var body: some View {
        HStack{
            Text("You have \(Antimatter.shared.state.amGalaxies) galaxies")
            Button(action: Antimatter.shared.buyGalaxy) {
                Text("\(Antimatter.shared.galaxyCost) 8th dimensions").contentShape(.rect)
            }.disabled(!Antimatter.shared.canBuyGalaxy)
        }
    }
}
