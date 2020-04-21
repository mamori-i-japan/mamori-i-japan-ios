// Copyright (c) 2020- Masakazu Ohtsuka / maaash.jp
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
// DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
// OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE
// OR OTHER DEALINGS IN THE SOFTWARE.

import Foundation
import CoreBluetooth

let PeripheralCharactersticUserInfoKey = "PeripheralCharactersticUserInfoKey"

class Peripheral: NSObject {
    let peripheral: CBPeripheral!
    private let services: [Service]
    private var commands: [Command]
    private var currentCommand: Command?
    private var didUpdateValue: CharacteristicDidUpdateValue?
    private var didReadRSSI: DidReadRSSI?

    var id: UUID {
        return peripheral.identifier
    }

    init(peripheral: CBPeripheral, services: [Service], commands: [Command], didUpdateValue: CharacteristicDidUpdateValue?, didReadRSSI: DidReadRSSI?) {
        self.peripheral = peripheral
        self.commands = commands
        self.services = services
        self.didUpdateValue = didUpdateValue
        self.didReadRSSI = didReadRSSI
        super.init()
        self.peripheral.delegate = self
    }

    func discoverServices() {
        let cbuuids = services.map { $0.toCBUUID() }
        peripheral.discoverServices(cbuuids)
    }

    func nextCommand() {
        if commands.count == 0 {
            currentCommand = nil
            return
        }
        print()
        currentCommand = commands[0]
        commands = commands.shift()
        execute(currentCommand!)
    }

    func execute(_ command: Command) {
        switch command {
        case .Read(let from):
            if let ch = toCBCharacteristic(c12c: from) {
                peripheral.readValue(for: ch)
            }
        case .Write(let to, let value):
            if let ch = toCBCharacteristic(c12c: to) {
                peripheral.writeValue(value(self), for: ch, type: .withoutResponse)
            }
            nextCommand()
        case .ReadRSSI:
            peripheral.readRSSI()
        case .Cancel(let callback):
            callback(self)
        }
    }

    func writeValue(value: Data, forCharacteristic ch: Characteristic, type: CBCharacteristicWriteType) {
        if let c = self.toCBCharacteristic(c12c: ch) {
            self.peripheral.writeValue(value, for: c, type: type)
        } else {
            print("c12c=\(ch) not found")
        }
    }

    func readValueForCharacteristic(c12c: Characteristic) throws {
        guard let c = self.toCBCharacteristic(c12c: c12c) else {
            print("c12c=\(c12c) not found")
            return
        }
        print("reading=\(c12c)")
        self.peripheral.readValue(for: c)
    }

    // MARK: - private utilities

    func toCBCharacteristic(c12c: Characteristic) -> CBCharacteristic? {
        let findingC12CUUID = c12c.toCBUUID()
        let findingServiceUUID = c12c.toService().toCBUUID()
        if let services = self.peripheral.services {
            let foundService = services.first { service in
                findingServiceUUID.isEqual(service.uuid)
            }
            if let c12cs = foundService?.characteristics {
                return c12cs.first { c in
                    findingC12CUUID.isEqual(c.uuid)
                }
            }
        }
        return nil
    }
}

extension Peripheral: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("services=\(String(describing: peripheral.services)), error=\(String(describing: error))")
        guard let discoveredServices = peripheral.services else { return }

        for discoveredService in discoveredServices {
            peripheral.discoverCharacteristics(nil, for: discoveredService)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        print("service=\(service), ch=\(String(describing: service.characteristics)), error=\(String(describing: error))")
        if error != nil {
            return
        }

        nextCommand()
    }

    // This might happen regardless of calling or not calling readValue(for:)
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        print("peripheral=\(peripheral.identifier), ch=\(String(describing: Characteristic.fromCBCharacteristic(characteristic)))")
        if let ch = Characteristic.fromCBCharacteristic(characteristic) {
            didUpdateValue?(self, ch, characteristic.value, error)
            if case .Read(let readCh) = currentCommand {
                if readCh == ch {
                    // Read complete
                    nextCommand()
                }
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        print("peripheral=\(peripheral.identifier), RSSI=\(RSSI), error=\(String(describing: error))")
        if case .ReadRSSI = currentCommand {
            // ReadRSSI complete
            nextCommand()
        }
    }
}

public extension Array {
    func shift() -> Array {
        if count == 0 {
            return []
        }
        return Array(self[1..<self.count])
    }
}
