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

class PeripheralManager: NSObject {
    typealias OnRead = (CBCentral, Characteristic) -> (Data?)
    typealias OnWrite = (CBCentral, Characteristic, Data) -> (Bool)

    private var started: Bool = false
    private var peripheralManager: CBPeripheralManager!
    private var onRead: OnRead?
    private var onWrite: OnWrite?

    private let peripheralName: String
    private let services: [CBMutableService]

    init(peripheralName: String, queue: DispatchQueue, services: [CBMutableService]) {
        let options = [CBPeripheralManagerOptionRestoreIdentifierKey: "com.decurret.TraceCovid19JP.PeripheralManager"]
        self.peripheralName = peripheralName
        self.services = services
        super.init()

        peripheralManager = CBPeripheralManager(delegate: self, queue: queue, options: options)
    }

    func turnOn() {
        started = true
        startAdvertising()
    }

    func turnOff() {
        started = false
        stopAdvertising()
    }

    func getState() -> CBManagerState {
        return peripheralManager.state
    }

    private func startAdvertising() {
        guard peripheralManager.state == .poweredOn else { return }

        if peripheralManager.isAdvertising {
            log("Already advertising")
            return
        }

        peripheralManager.removeAllServices()

        services.forEach { service in
            peripheralManager.add(service)
        }
        let uuids = services.map { service in service.uuid }
        let advertisementData: [String: Any] = [
            CBAdvertisementDataLocalNameKey: peripheralName,
            CBAdvertisementDataServiceUUIDsKey: uuids
        ]
        peripheralManager.startAdvertising(advertisementData)
    }

    private func stopAdvertising() {
        peripheralManager.stopAdvertising()
    }

    func onRead(callback :@escaping PeripheralManager.OnRead) -> PeripheralManager {
        onRead = callback
        return self
    }

    func onWrite(callback :@escaping PeripheralManager.OnWrite) -> PeripheralManager {
        onWrite = callback
        return self
    }
}

extension PeripheralManager: CBPeripheralManagerDelegate {
    public func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        log("state=\(peripheral.state.toString)")
        if peripheral.state == .poweredOn && started {
            startAdvertising()
        }
    }

    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        log("error=\(String(describing: error))")
    }

    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        log("request=\(request)")

        guard let ch = Characteristic.fromCBCharacteristic(request.characteristic), let onRead = onRead else {
            peripheralManager.respond(to: request, withResult: .requestNotSupported)
            return
        }
        if let data = onRead(request.central, ch) {
            request.value = data
            peripheral.respond(to: request, withResult: .success)
        }
        peripheralManager.respond(to: request, withResult: .unlikelyError)
    }

    // https://developer.apple.com/documentation/corebluetooth/cbperipheralmanagerdelegate/1393315-peripheralmanager
    // When you respond to a write request, note that the first parameter of the respond(to:withResult:) method expects a single CBATTRequest object, even though you received an array of them from the peripheralManager(_:didReceiveWrite:) method. To respond properly, pass in the first request of the requests array.
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        log("requests=\(requests)")

        if requests.count == 0 {
            return
        }

        var success = false
        requests.forEach { request in
            guard let ch = Characteristic.fromCBCharacteristic(request.characteristic), let onWrite = onWrite, let val = request.value else {
                return
            }
            if onWrite(request.central, ch, val) {
                success = true
            }
        }
        peripheralManager.respond(to: requests[0], withResult: success ? .success : .unlikelyError)
    }

    func peripheralManager(_ peripheral: CBPeripheralManager, willRestoreState dict: [String: Any]) {
        log("dict=\(dict)")
    }
}
