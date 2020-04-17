//
//  CoreDataService.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/12.
//

import Foundation
import CoreData

final class CoreDataService {
    private(set) var persistentContainer: NSPersistentContainer

    /// CoreDataで管理する全クラス **＊全削除に使用するため必ずクラスが増える場合は定義すること**
    private let managedClasses: [NSManagedObject.Type] = [TraceData.self, DeepContactUser.self, TempUserId.self]

    init(persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
    }

    func getFetchRequestFor<T>(_ classObject: T.Type, context: NSManagedObjectContext, with predicate: NSPredicate?, with sortDescriptor: NSSortDescriptor?, prefetchKeyPaths prefetchKeypaths: [Any]?, fetchLimit: Int = -1)
        -> NSFetchRequest<T> where T: NSManagedObject {
        let fetchRequest = NSFetchRequest<T>()
        let entityDescription = NSEntityDescription.entity(forEntityName: NSStringFromClass(classObject.self), in: context)
        fetchRequest.entity = entityDescription

        if predicate != nil {
            fetchRequest.predicate = predicate
        }
        if sortDescriptor != nil {
            fetchRequest.sortDescriptors = [sortDescriptor] as? [NSSortDescriptor]
        }
        if prefetchKeypaths != nil {
            fetchRequest.relationshipKeyPathsForPrefetching = prefetchKeypaths as? [String]
        }

        if fetchLimit > 0 {
            fetchRequest.fetchLimit = fetchLimit
        }

        return fetchRequest
    }

    func getObjectsOf<T>(_ classObject: T.Type, with predicate: NSPredicate?, with sortDescriptor: NSSortDescriptor?, prefetchKeyPaths prefetchKeypaths: [Any]?, fetchLimit: Int = -1) -> [T]? where T: NSManagedObject {
        let context = persistentContainer.viewContext

        let fetchRequest = getFetchRequestFor(classObject, context: context, with: predicate, with: sortDescriptor, prefetchKeyPaths: prefetchKeypaths, fetchLimit: fetchLimit)

        var result: [T]!

        do {
            result = try context.fetch(fetchRequest)
        } catch {
            print("Error occured: \(error). Error description : \(error.localizedDescription)")
        }

        if result == nil {
            result = [T]()
        }

        return result
    }

    func delete(object: NSManagedObject) {
        let context = persistentContainer.viewContext
        context.perform { [weak self] in
            context.delete(object)
            self?.saveDatabaseContext()
        }
    }

    func deleteObjectsOf<T>(_ classObject: T.Type, with predicate: NSPredicate?) where T: NSManagedObject {
        let context = persistentContainer.viewContext

        context.perform { [weak self] in
            guard let objectsToDelete = self?.getObjectsOf(classObject, with: predicate, with: nil, prefetchKeyPaths: nil) else { return }
            for object in objectsToDelete {
                context.delete(object)
                self?.saveDatabaseContext()
            }
        }
    }

    func deleteAll() {
        managedClasses.forEach { deleteObjectsOf($0, with: nil) }
    }

    func saveDatabaseContext () {
        let context = persistentContainer.viewContext

        if context.hasChanges {
            context.perform {
                do {
                    try context.save()
                } catch {
                    let nserror = error as NSError
                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                }
            }
        }
    }
}
