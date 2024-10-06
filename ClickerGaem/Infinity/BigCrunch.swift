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
        Antimatter.shared.state.antimatter.gte(other: Decimals.infinity)
    }
    
    func crunch() {
        guard canBigCrunch else {
            return
        }
        antimatterState.reset()
        // Start with 100 instead of 10
        antimatterState.antimatter = 100
        Infinity.shared.add(infinities: 1)
        Dimensions.shared.dimensions.forEach({$1.reset()})
    }
}

struct FirstBigCrunch: ViewModifier {
    var bigCrunch: BigCrunch {
        BigCrunch.shared
    }
    
    func body(content: Content) -> some View {
        if bigCrunch.canBigCrunch && !Infinity.shared.state.infinityBroken {
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
