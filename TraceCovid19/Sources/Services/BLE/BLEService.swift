//
//  BLEService.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/10.
//

import UIKit
import CoreBluetooth

enum Service: String, CustomStringConvertible {
    // TODO currently from https://github.com/TCNCoalition/TCN
    case trace = "0000C019-0000-1000-8000-00805F9B34FB"
    func toCBUUID() -> CBUUID {
        return CBUUID(string: self.rawValue)
    }
    var description: String {
        switch self {
        case .trace:
            return "trace"
        }
    }
}

enum Characteristic: String, CustomStringConvertible {
    // TODO currently from https://github.com/TCNCoalition/TCN
    case contact = "D61F4F27-3D6B-4B04-9E46-C9D2EA617F62"

    func toService() -> Service {
        switch self {
        case .contact:
            return .trace
        }
    }
    func toCBUUID() -> CBUUID {
        return CBUUID(string: self.rawValue)
    }
    var description: String {
        switch self {
        case .contact:
            return "contact"
        }
    }
    static func fromCBCharacteristic(_ c: CBCharacteristic) -> Characteristic? {
        return Characteristic(rawValue: c.uuid.uuidString)
    }
}

enum Command: CustomStringConvertible {
    case read(from: Characteristic)
    case write(to: Characteristic, value: (Peripheral) -> (Data?))
    case readRSSI
    case cancel(callback: (Peripheral) -> Void)
    var description: String {
        switch self {
        case .read:
            return "read"
        case .write:
            return "write"
        case .readRSSI:
            return "readRSSI"
        case .cancel:
            return "cancel"
        }
    }
}

typealias CharacteristicDidUpdateValue = (Peripheral, Characteristic, Data?, Error?) -> Void
typealias DidReadRSSI = (Peripheral, NSNumber, Error?) -> Void

// BLEService holds all the business logic related to BLE.
final class BLEService {
    private var peripheralManager: PeripheralManager!
    private var centralManager: CentralManager!
    private var coreData: CoreDataService!
    private var tempId: TempIdService!
    private var timerForScanning: Timer?
    private var traceData: [UUID: TraceDataRecord]!

    private let queue: DispatchQueue!
    var bluetoothDidUpdateStateCallback: ((CBManagerState) -> Void)?

    init(
        queue: DispatchQueue,
        peripheralManager: PeripheralManager,
        centralManager: CentralManager,
        coreData: CoreDataService,
        tempId: TempIdService
    ) {
        self.queue = queue
        self.peripheralManager = peripheralManager
        self.centralManager = centralManager
        self.coreData = coreData
        self.tempId = tempId
        self.traceData = [:]
        centralManager.centralDidUpdateStateCallback = centralDidUpdateStateCallback

        _ = self.peripheralManager
            // Central is trying to read from us
            .onRead { [unowned self] _, ch in
                switch ch {
                case .contact:
                    guard let userId = self.tempId.currentTempId ?? self.tempId.latestTempId else {
                        log("not found temp user id on CoreData")
                        return nil
                    }

                    let payload = ReadData(tempID: userId.tempId)
                    return payload.data
                }
            }
            // Central is trying to write into us
            .onWrite { [unowned self] _, ch, data in
                switch ch {
                case .contact:
                    guard let writeData = WriteData(from: data) else {
                        let str = String(data: data, encoding: .utf8)
                        log("failed to deserialize data=\(String(describing: str))")
                        return false
                    }
                    self.coreData.save(traceDataRecord: TraceDataRecord(from: writeData))
                    return true
                }
            }

        // Commands and callbacks should happen in this order
        _ = self.centralManager
            .appendCommand(
                command: .readRSSI
            )
            .didReadRSSI { [unowned self] peripheral, RSSI, error in
                log("peripheral=\(peripheral.shortId), RSSI=\(RSSI), error=\(String(describing: error))")

                guard error == nil else {
                    self.centralManager.disconnect(peripheral)
                    return
                }
                var record = self.traceData[peripheral.id] ?? TraceDataRecord()
                record.rssi = RSSI.doubleValue
                self.traceData[peripheral.id] = record
            }
            .appendCommand(
                command: .write(to: .contact, value: { [unowned self] peripheral in
                    let record = self.traceData[peripheral.id] ?? TraceDataRecord()
                    guard let userId = self.tempId.currentTempId ?? self.tempId.latestTempId else {
                        return nil
                    }

                    // TODO txPower
                    let writeData = WriteData(RSSI: record.rssi ?? 0, tempID: userId.tempId)
                    return writeData.data
                })
            )
            .appendCommand(
                command: .read(from: .contact)
            )
            .didUpdateValue { [unowned self] peripheral, ch, data, error in
                log("didUpdateValueFor peripheral=\(peripheral.shortId), ch=\(ch), data=\(String(describing: data)), error=\(String(describing: error))")

                guard error == nil && data != nil else {
                    self.centralManager.disconnect(peripheral)
                    return
                }

                guard let readData = ReadData(from: data!) else {
                    self.centralManager.disconnect(peripheral)
                    return
                }
                var record = self.traceData[peripheral.id] ?? TraceDataRecord()
                record.tempId = readData.i
                record.timestamp = Date()
                self.traceData[peripheral.id] = record

                log("save: \(record.tempId ?? "nil")")
                self.coreData.save(traceDataRecord: record)
            }
            .appendCommand(
                command: .cancel(callback: { [unowned self] peripheral in
                    self.centralManager.disconnect(peripheral)
                })
            )
    }

    func turnOn() {
        peripheralManager.turnOn()
        centralManager.turnOn()
    }

    func turnOff() {
        peripheralManager.turnOff()
        centralManager.turnOff()
    }

    func getCentralStateText() -> String {
        return centralManager.getState().toString
    }

    func getPeripheralStateText() -> String {
        return peripheralManager.getState().toString
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
        switch centralManager.getState() {
        case .poweredOff:
            log("[BLEService] Bluetooth is off")
        case .resetting:
            log("[BLEService] Resetting State")
        case .unauthorized:
            log("[BLEService] Unauth State")
        case .unknown:
            log("[BLEService] Unknown State")
        case .unsupported:
            centralManager.turnOn()
            log("[BLEService] Unsupported State")
        default:
            log("[BLEService] Bluetooth is on")
        }
        return centralManager.getState() == CBManagerState.poweredOn
    }

    func centralDidUpdateStateCallback(_ state: CBManagerState) {
        bluetoothDidUpdateStateCallback?(state)
        switch state {
        case .poweredOn:
            DispatchQueue.main.async { [unowned self] in
                self.timerForScanning = Timer.scheduledTimer(withTimeInterval: TimeInterval(BluetraceConfig.CentralScanInterval), repeats: true) { [weak self] _ in
                    log("Restarting a scan")
                    self?.coreData.saveTraceDataWithCurrentTime(for: .scanningStopped)
                    self?.coreData.saveTraceDataWithCurrentTime(for: .scanningStarted)

                    self?.traceData = [:]
                    self?.centralManager.restartScan()
                }
                self.timerForScanning?.fire()
            }
        default:
            timerForScanning?.invalidate()
        }
    }

    func toggleAdvertisement(_ state: Bool) {
        if state {
            peripheralManager.turnOn()
        } else {
            peripheralManager.turnOff()
        }
    }

    func toggleScanning(_ state: Bool) {
        if state {
            centralManager.turnOn()
        } else {
            centralManager.turnOff()
        }
    }
}
