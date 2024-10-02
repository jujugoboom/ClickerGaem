//
//  BigCrunch.swift
//  ClickerGaem
//
//  Created by Justin Covell on 9/22/24.
//

import SwiftUI

class BigCrunch {
    static var shared = BigCrunch()
    
    var state: GameState {
        GameInstance.shared.state
    }
    
    var antimatterState: AntimatterState {
        Antimatter.shared.state
    }
    
    var canBigCrunch: Bool {
        Antimatter.shared.state.antimatter.gte(other: InfiniteDecimal(mantissa: 1.8, exponent: 308))
    }
    
    func crunch() {
        guard canBigCrunch else {
            return
        }
        antimatterState.antimatter = 100
        antimatterState.dimensionBoosts = 0
        antimatterState.sacrificedDimensions = 0
        antimatterState.amGalaxies = 0
        antimatterState.tickSpeedUpgrades = 0
        state.firstInfinity = true
        Dimensions.shared.dimensions.forEach({$1.reset()})
    }
}

struct FirstBigCrunch: ViewModifier {
    var bigCrunch: BigCrunch {
        BigCrunch.shared
    }
    
    func body(content: Content) -> some View {
        if bigCrunch.canBigCrunch && !Statistics.shared.firstInfinity {
            Button(action: bigCrunch.crunch) {
                Text("BIG CRUNCH").padding()
            }.padding().background().clipShape(RoundedRectangle(cornerRadius: 10)).shadow(radius: 5)
        } else {
            content
        }
    }
    
}

extension View {
    func firstBigCrunch() -> some View {
        modifier(FirstBigCrunch())
    }
}
