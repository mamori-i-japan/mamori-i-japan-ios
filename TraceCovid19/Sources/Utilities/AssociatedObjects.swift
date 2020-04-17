//
//  AssociatedObjects.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/09.
//

import Foundation

/// ExtensionにpropertyをはやすためのAssociatedObjectsを定義するプロトコル
protocol HasAssociatedObjects {
    var associatedObjects: AssociatedObjects { get }
}

private var AssociatedObjectsKey: UInt8 = 0
extension HasAssociatedObjects where Self: AnyObject {
    var associatedObjects: AssociatedObjects {
        guard let associatedObjects = objc_getAssociatedObject(self, &AssociatedObjectsKey) as? AssociatedObjects else {
            let associatedObjects = AssociatedObjects()
            objc_setAssociatedObject(self, &AssociatedObjectsKey, associatedObjects, .OBJC_ASSOCIATION_RETAIN)
            return associatedObjects
        }
        return associatedObjects
    }
}

class AssociatedObjects: NSObject {
    private var dictionary: [String: Any] = [:]

    subscript(key: String) -> Any? {
        get {
            return dictionary[key]
        }
        set {
            dictionary[key] = newValue
        }
    }
}
