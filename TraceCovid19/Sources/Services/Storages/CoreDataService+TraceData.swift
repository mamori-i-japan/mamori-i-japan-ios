//
//  CoreDataService+TraceData.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/12.
//

import UIKit
import CoreData

extension CoreDataService {
    func getTraceDataList() -> [TraceDataEntity] {
        let managedContext = persistentContainer.viewContext
        let request = getFetchRequestFor(TraceDataEntity.self, context: managedContext, with: nil, with: NSSortDescriptor(key: "timestamp", ascending: false), prefetchKeyPaths: nil)

        do {
            // TODO: performBlockなどでの考慮を入れる
            let traceData = try managedContext.fetch(request)
            return traceData
        } catch {
            print("[CoreData] error occured: \(error)")
            return []
        }
    }

    func getAllTempIDsOfTraceData() -> [String] {
        let context = persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "TraceData")
        request.entity = NSEntityDescription.entity(forEntityName: "TraceData", in: context)
        request.propertiesToFetch = ["tempId"]
        request.resultType = .dictionaryResultType
        request.returnsDistinctResults = true

        do {
            // TODO: performBlockなどでの考慮を入れる
            let traceData: [Any] = try context.fetch(request)
            print("[CoreData] read success")
            return traceData.compactMap { result -> String? in
                (result as AnyObject).value(forKey: "tempId") as? String
            }.filter { $0.isValidTempId }
        } catch {
            print("[CoreData] error occured: \(error)")
            return []
        }
    }

    func getTraceDataList(tempID: String) -> [TraceDataEntity] {
        // NOTE: 取得に時間がかかるのでスレッドを分けるのを推奨
        let managedContext = persistentContainer.viewContext
        let predicate = NSPredicate(format: "tempId = %@", tempID)
        let request = getFetchRequestFor(TraceDataEntity.self, context: managedContext, with: predicate, with: NSSortDescriptor(key: "timestamp", ascending: false), prefetchKeyPaths: nil)

        do {
            // TODO: performBlockなどでの考慮を入れる
            let traceData = try managedContext.fetch(request)
            return traceData.filter { $0.isValidConnection }
        } catch {
            print("[CoreData] error occured: \(error)")
            return []
        }
    }

    /// TempIDと時間範囲指定での削除
    /// - Parameter tempId:
    func deleteAllTraceData(tempId: String, startTime: Date, endTime: Date) {
        deleteObjectsOf(TraceDataEntity.self, with: NSPredicate(format: "tempId = %@ AND (timestamp >= %@) AND (timestamp <= %@)", tempId, startTime as NSDate, endTime as NSDate))
    }

    func deleteAllTraceData() {
        deleteObjectsOf(TraceDataEntity.self, with: nil)
    }

    enum Event: String {
        // Deprecated
        case scanningStarted = "Scanning started"
        // Deprecated
        case scanningStopped = "Scanning stopped"

        case scanningRestarted = "Scanning restarted"
    }

    func saveTraceDataWithCurrentTime(for event: Event) {
        DispatchQueue.main.async { [weak self] in
            guard let sSelf = self else { return }
            let managedContext = sSelf.persistentContainer.viewContext
            let entity = NSEntityDescription.entity(forEntityName: "TraceData", in: managedContext)!
            let data = TraceDataEntity(entity: entity, insertInto: managedContext)
            data.tempId = event.rawValue
            data.timestamp = Date()
            do {
                // TODO: performBlockなどでの考慮を入れる
                try managedContext.save()
                print("[CoreData] save (\(event.rawValue))")
            } catch {
                print("[CoreData] Could not save. \(error)")
            }
        }
    }
}
