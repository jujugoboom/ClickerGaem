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
        VStack {
            Text("You have \(state?.antimatter ?? 0) antimatter")
            Text("You are getting \(state?.amPerSecond ?? 0) AM/s")
            Text("Total tickspeed: \(state?.ticksPerSecond ?? 0)/s")
            Button(action: buyTickspeedUpgrade) {
                Text("Buy tickspeed upgrade for \(state?.tickspeedUpgradeCost ?? 0)")
            }.disabled(state?.tickspeedUpgradeCost.gt(other: state?.antimatter ?? 0) ?? true)
            List {ForEach(state?.unlockedDimensions ?? []) { dimension in
                DimensionView(dimension: dimension)
            }}
            if let gameState = state {
                DimensionBoost(gameState: gameState)
            }
        }.onAppear(perform: initGame)
    }
    
    private func buyTickspeedUpgrade() {
        let antimatter = state?.antimatter
        let tickspeedUpgradeCost = state?.tickspeedUpgradeCost
        guard antimatter != nil && tickspeedUpgradeCost != nil else {
            return
        }
        guard antimatter!.gt(other: tickspeedUpgradeCost!) else {
            return
        }
        state?.antimatter = antimatter!.sub(value: tickspeedUpgradeCost!)
        state?.tickSpeedUpgrades = (state?.tickSpeedUpgrades.add(value: 1))!
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
