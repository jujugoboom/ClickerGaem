//
//  BigCrunch.swift
//  ClickerGaem
//
//  Created by Justin Covell on 9/22/24.
//

import SwiftUI

struct FirstBigCrunch: ViewModifier {
    @Environment(GameInstance.self) var gameInstance: GameInstance
    var antimatter: Antimatter {
        gameInstance.antimatter
    }
    var infinity: Infinity {
        gameInstance.infinity
    }
    @State private var _canCrunch = false
    
    var canCrunch: Bool{
        get {
            guard !_canCrunch else {
                return _canCrunch
            }
            _canCrunch = antimatter.antimatter.gte(other: Decimals.infinity)
            guard _canCrunch else {
                return _canCrunch
            }
            infinity.infinityTime = Date()
            return _canCrunch
        }
    }
    
    func body(content: Content) -> some View {
        if canCrunch && !infinity.infinityBroken {
            Button(action: crunch) {
                Text("BIG CRUNCH").padding()
            }.padding().background().clipShape(RoundedRectangle(cornerRadius: 10)).shadow(radius: 5)
        } else {
            content
        }
    }
    
    func crunch() {
        guard canCrunch else { return }
        infinity.add(infinities: 1)
        infinity.infinityStartTime = Date()
        antimatter.reset()
        antimatter.antimatter = 100
        antimatter.dimensions.dimensions.values.forEach() { dimension in
            dimension.reset()
        }
    }
    
}

extension View {
    func firstBigCrunch() -> some View {
        modifier(FirstBigCrunch())
    }
}
