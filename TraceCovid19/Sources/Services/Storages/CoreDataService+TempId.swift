//
//  CoreDataService+TempId.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/17.
//

import Foundation
import CoreData

extension CoreDataService {
    func save(tempID: TempIdStruct) {
        // NOTE: 同じTempIDだったとしてもCoreData上では重複するので、排除してからsaveを実行すること
        let managedContext = persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "TempUserId", in: managedContext)!
        let tempUserId = TempUserId(entity: entity, insertInto: managedContext)
        tempUserId.set(tempIdStruct: tempID)
        print("[CoreData] save: \(tempUserId)")
        do {
            try managedContext.save()
        } catch {
            print("[CoreData] Could not save. \(error)")
        }
    }

    func getTempUserIDs() -> [TempIdStruct] {
        let managedContext = persistentContainer.viewContext
        let request = getFetchRequestFor(TempUserId.self, context: managedContext, with: nil, with: NSSortDescriptor(key: "startTime", ascending: false), prefetchKeyPaths: nil)

        do {
            let result = try managedContext.fetch(request)
            return result.compactMap { $0.toTempIdStruct() }
        } catch {
            print("[CoreData] error occured: \(error)")
            return []
        }
    }

    func deleteAllTempUserIDs() {
        deleteObjectsOf(TempUserId.self, with: nil)
    }
}
