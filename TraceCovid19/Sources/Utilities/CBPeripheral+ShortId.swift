import Foundation
import CoreBluetooth

extension CBPeripheral {
    var shortId: String {
        String(identifier.uuidString.prefix(8))
    }
}
