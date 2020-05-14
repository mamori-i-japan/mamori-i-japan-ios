//
//  CoreDataService+TempId.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/17.
//

import Foundation
import CoreData

extension CoreDataService {
    func save(tempUserId: TempUserId) {
        // NOTE: 同じTempIDだったとしてもCoreData上では重複するので、排除してからsaveを実行すること
        let managedContext = persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "TempUserId", in: managedContext)!
        let tempUserIdEntity = TempUserIdEntity(entity: entity, insertInto: managedContext)
        tempUserIdEntity.set(tempUserId: tempUserId)
        print("[CoreData] save: \(tempUserId)")
        do {
            // TODO: performBlockなどでの考慮を入れる
            try managedContext.save()
        } catch {
            print("[CoreData] Could not save. \(error)")
        }
    }

    func getTempUserIDs() -> [TempUserId] {
        let managedContext = persistentContainer.viewContext
        let request = getFetchRequestFor(TempUserIdEntity.self, context: managedContext, with: nil, with: NSSortDescriptor(key: "startTime", ascending: false), prefetchKeyPaths: nil)

        do {
            // TODO: performBlockなどでの考慮を入れる
            let result = try managedContext.fetch(request)
            return result.compactMap { $0.toTempUserId() }
        } catch {
            print("[CoreData] error occured: \(error)")
            return []
        }
    }

    func deleteAllTempUserIDs() {
        deleteObjectsOf(TempUserIdEntity.self, with: nil)
    }
}
