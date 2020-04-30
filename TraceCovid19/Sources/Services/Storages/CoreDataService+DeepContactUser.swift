//
//  CoreDataService+DeepContactUser.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/15.
//

import Foundation
import CoreData

extension CoreDataService {
    func saveAsDeepContactUser(tempId: String, traceData: [TraceDataRecord]) {
        let managedContext = persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "DeepContactUser", in: managedContext)!
        let deepContactUser = DeepContactUserEntity(entity: entity, insertInto: managedContext)
        guard deepContactUser.set(tempId: tempId, traceData: traceData) else {
            print("[CoreData] Could not set to deep contact user entity: \(tempId)")
            return
        }
        print("[CoreData] save: \(deepContactUser)")
        do {
            try managedContext.save()
        } catch {
            print("[CoreData] Could not save. \(error)")
        }
    }

    func getDeepContactUsers() -> [DeepContactUserEntity] {
        let managedContext = persistentContainer.viewContext
        let request = getFetchRequestFor(DeepContactUserEntity.self, context: managedContext, with: nil, with: NSSortDescriptor(key: "startTime", ascending: false), prefetchKeyPaths: nil)

        do {
            let result = try managedContext.fetch(request)
            return result
        } catch {
            print("[CoreData] error occured: \(error)")
            return []
        }
    }

    func deleteAllDeepContactUsers() {
        deleteObjectsOf(DeepContactUserEntity.self, with: nil)
    }
}
