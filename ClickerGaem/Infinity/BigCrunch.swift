//
//  BigCrunch.swift
//  ClickerGaem
//
//  Created by Justin Covell on 9/22/24.
//

import SwiftUI

struct FirstBigCrunch: ViewModifier {
    func body(content: Content) -> some View {
        if Infinity.shared.canCrunch && !Infinity.shared.state.infinityBroken {
            Button(action: Infinity.shared.crunch) {
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
