import Foundation
import CoreBluetooth

extension CBPeripheral {
    var shortId: String {
        return String(identifier.uuidString.prefix(8))
    }
}
