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

    private var queue: DispatchQueue
    private let services: [Service]
    private var commands: [Command]
    private var currentCommand: Command?
    private var didUpdateValue: CharacteristicDidUpdateValue?
    private var didReadRSSI: DidReadRSSI?
    private var timer: Timer?

    var id: UUID {
        return peripheral.identifier
    }
    var shortId: String {
        return peripheral.shortId
    }

    init(peripheral: CBPeripheral, queue: DispatchQueue, services: [Service], commands: [Command], didUpdateValue: CharacteristicDidUpdateValue?, didReadRSSI: DidReadRSSI?) {
        self.peripheral = peripheral
        self.queue = queue
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
        currentCommand = commands[0]
        log("currentCommand=\(currentCommand!)")
        commands = commands.shift()
        execute(currentCommand!)
    }

    func execute(_ command: Command) {
        switch command {
        case .read(let from):
            if let ch = toCBCharacteristic(c12c: from) {
                peripheral.readValue(for: ch)
            }
        case .write(let to, let value):
            if let ch = toCBCharacteristic(c12c: to), let val = value(self) {
                peripheral.writeValue(val, for: ch, type: .withoutResponse)
            }
            nextCommand()
        case .readRSSI:
            peripheral.readRSSI()
        case .scheduleCommands(let newCommands, let withTimeInterval, let repeatCount):
            if repeatCount == 0 {
                // Schedule finished
                nextCommand()
                return
            }
            timer = Timer(timeInterval: withTimeInterval, repeats: false) { [weak self] _ in
                self?.queue.async {
                    // Scheduled commands get executed first,
                    var nextCommands = newCommands
                    // and then continue the schedule,
                    nextCommands.append(.scheduleCommands(commands: newCommands, withTimeInterval: withTimeInterval, repeatCount: repeatCount - 1))
                    // and then continue the rest.
                    nextCommands.append(contentsOf: self?.commands ?? [])
                    self?.commands = nextCommands
                    self?.nextCommand()
                }
            }
            RunLoop.current.add(timer!, forMode: .common)

        case .cancel(let callback):
            timer?.invalidate()
            callback(self)
        }
    }

    func writeValue(value: Data, forCharacteristic ch: Characteristic, type: CBCharacteristicWriteType) {
        if let c = self.toCBCharacteristic(c12c: ch) {
            self.peripheral.writeValue(value, for: c, type: type)
        } else {
            log("c12c=\(ch) not found")
        }
    }

    func readValueForCharacteristic(c12c: Characteristic) throws {
        guard let c = self.toCBCharacteristic(c12c: c12c) else {
            log("c12c=\(c12c) not found")
            return
        }
        log("reading=\(c12c)")
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
        guard let discoveredServices = peripheral.services else { return }

        for discoveredService in discoveredServices {
            peripheral.discoverCharacteristics(nil, for: discoveredService)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if error != nil {
            return
        }

        nextCommand()
    }

    // This might happen regardless of calling or not calling readValue(for:)
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        log("peripheral=\(shortId), ch=\(String(describing: Characteristic.fromCBCharacteristic(characteristic)))")
        if let ch = Characteristic.fromCBCharacteristic(characteristic) {
            didUpdateValue?(self, ch, characteristic.value, error)
            if case .read(let readCh) = currentCommand {
                if readCh == ch {
                    // Read complete
                    nextCommand()
                }
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        log("peripheral=\(shortId), RSSI=\(RSSI), error=\(String(describing: error))")
        if case .readRSSI = currentCommand {
            didReadRSSI?(self, RSSI, error)
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
