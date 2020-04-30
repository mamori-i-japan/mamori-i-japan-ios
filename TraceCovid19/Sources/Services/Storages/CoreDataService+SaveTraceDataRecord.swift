//
//  CoreDataService+SaveTraceDataRecord.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/12.
//

import UIKit
import CoreData

extension CoreDataService {
    func save(traceDataRecord: TraceDataRecord) {
        let managedContext = persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "TraceData", in: managedContext)!
        let data = TraceDataEntity(entity: entity, insertInto: managedContext)
        data.set(traceDataRecord: traceDataRecord)
        print("[CoreData] save: \(data)")
        do {
            try managedContext.save()
        } catch {
            print("[CoreData] Could not save. \(error)")
        }
    }
}
