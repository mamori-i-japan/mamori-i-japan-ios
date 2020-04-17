//
//  BLEService.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/10.
//

import UIKit
import CoreBluetooth

final class BLEService {
    private var peripheralController: PeripheralController!
    private var centralController: CentralController!

    private let queue: DispatchQueue!
    var bluetoothDidUpdateStateCallback: ((CBManagerState) -> Void)?

    init(
        queue: DispatchQueue,
        peripheralController: PeripheralController,
        centralController: CentralController
    ) {
        self.queue = queue
        self.peripheralController = peripheralController
        self.centralController = centralController
        centralController.centralDidUpdateStateCallback = centralDidUpdateStateCallback
    }

    func turnOn() {
        peripheralController.turnOn()
        centralController.turnOn()
    }

    func turnOff() {
        peripheralController.turnOff()
        centralController.turnOff()
    }

    func getCentralStateText() -> String {
        return centralController.getState()?.toString ?? "nil"
    }

    func getPeripheralStateText() -> String {
        return peripheralController.getState().toString
    }

    func isBluetoothAuthorized() -> Bool {
        if #available(iOS 13.1, *) {
            return CBManager.authorization == .allowedAlways
        } else {
            // todo: consider iOS 13.0, which has different behavior from 13.1 onwards
            return CBPeripheralManager.authorizationStatus() == .authorized
        }
    }

    func isBluetoothOn() -> Bool {
        switch centralController.getState() {
        case .poweredOff:
            print("Bluetooth is off")
        case .resetting:
            print("Resetting State")
        case .unauthorized:
            print("Unauth State")
        case .unknown:
            print("Unknown State")
        case .unsupported:
            centralController.turnOn()
            print("Unsupported State")
        default:
            print("Bluetooth is on")
        }
        return centralController.getState() == CBManagerState.poweredOn
    }

    func centralDidUpdateStateCallback(_ state: CBManagerState) {
        bluetoothDidUpdateStateCallback?(state)
    }

    func toggleAdvertisement(_ state: Bool) {
        if state {
            peripheralController.turnOn()
        } else {
            peripheralController.turnOff()
        }
    }

    func toggleScanning(_ state: Bool) {
        if state {
            centralController.turnOn()
        } else {
            centralController.turnOff()
        }
    }
}
