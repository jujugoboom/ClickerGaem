//
//  ContentView.swift
//  ClickerGaem
//
//  Created by Justin Covell on 9/13/24.
//

import SwiftUI
import CoreData
import OrderedCollections

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State var state: GameState?
    @State var game: GameInstance?
    
    var body: some View {
        TabView {
            if let gameState = state {
                AntimatterView(state: gameState).tabItem {
                    Label("Antimatter Dimensions", systemImage: "circle.and.line.horizontal")
                }
                AutobuyerView(gameState: gameState).tabItem {
                    Label("Autobuyers", systemImage: "autostartstop")
                }
            }
        }.onAppear(perform: initGame)
    }
    
    private func initGame() {
        do {
            let initState = try viewContext.fetch(NSFetchRequest<StoredGameState>(entityName: "StoredGameState"))
            if initState.isEmpty {
                let newState = GameState(antimatter: 10)
                state = newState
            } else {
                let storedState = initState[0]
                let storedDimensionStates = storedState.dimensionStates?.allObjects as? [StoredDimensionState] ?? []
                var dimensionStates: [DimensionState] = []
                for storedDimensionState in storedDimensionStates {
                    dimensionStates.append(DimensionState(tier: Int(storedDimensionState.tier), purchaseCount: Int(storedDimensionState.purchaseCount), currCount: storedDimensionState.currCount as! InfiniteDecimal, unlocked: storedDimensionState.unlocked))
                }
                state = GameState(updateInterval: storedState.updateInterval, antimatter: storedState.antimatter as! InfiniteDecimal, dimensionStates: dimensionStates)
            }
        } catch {
            assertionFailure("Failed to generate initial state")
            return
        }
        game = GameInstance(state: state!)
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, ClickerGaemData.preview.viewContext)
}
