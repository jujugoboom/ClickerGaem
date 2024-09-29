//
//  AutobuyerState.swift
//  ClickerGaem
//
//  Created by Justin Covell on 9/28/24.
//
import Foundation
import CoreData

@Observable
class AutobuyerState: Saveable {
    let id: String
    var enabled: Bool = false
    var unlocked: Bool = false
    var autobuyCount: Int = 0
    var storedState: StoredAutobuyerState? = nil
    
    init(id: String) {
        self.id = id
    }
    
    func load() {
        let req = StoredAutobuyerState.fetchRequest()
        req.fetchLimit = 1
        req.predicate = NSPredicate(format: "id == %@", id)
        guard let maybeStoredState = try? ClickerGaemData.shared.persistentContainer.viewContext.fetch(req).first else {
            storedState = StoredAutobuyerState(context: ClickerGaemData.shared.persistentContainer.viewContext)
            storedState?.id = id
            storedState?.unlocked = unlocked
            storedState?.enabled = enabled
            storedState?.autobuyCount = Int64(autobuyCount)
            return
        }
        storedState = maybeStoredState
        unlocked = storedState!.unlocked
        enabled = storedState!.enabled
        autobuyCount = Int(storedState!.autobuyCount)
    }
    
    func save(objectContext: NSManagedObjectContext, notification: NotificationCenter.Publisher.Output? = nil) {
        if storedState == nil {
            storedState = StoredAutobuyerState(context: objectContext)
        }
        storedState?.id = id
        storedState?.unlocked = unlocked
        storedState?.enabled = enabled
        storedState?.autobuyCount = Int64(autobuyCount)
        try? objectContext.save()
    }
    
    func reset() {
        self.enabled = false
        self.unlocked = false
        self.load()
    }
}

@Observable
class BuyableAutobuyerState: AutobuyerState {
    var purchased: Bool = false
    
    override func load() {
        super.load()
        purchased = self.storedState!.purchased
    }
    
    override func save(objectContext: NSManagedObjectContext, notification: NotificationCenter.Publisher.Output? = nil) {
        storedState?.purchased = purchased
        super.save(objectContext: objectContext, notification: notification)
    }
    
    override func reset() {
        purchased = false
        super.reset()
    }
}
