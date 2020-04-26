//
//  BLEService.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/10.
//

import UIKit
import CoreBluetooth

let traceDataRecordThrottleInterval: TimeInterval = 30

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
typealias DidDiscoverTxPower = (UUID, Double) -> Void

// BLEService holds all the business logic related to BLE.
final class BLEService {
    private var peripheralManager: PeripheralManager?
    private var centralManager: CentralManager?
    private var coreData: CoreDataService!
    private var tempId: TempIdService!
    private var timerForScanning: Timer?

    // Access traceData from the queue only, except in init, otherwise race can happen
    private var traceData: [UUID: TraceDataRecord]!

    private let queue: DispatchQueue!
    var bluetoothDidUpdateStateCallback: ((CBManagerState) -> Void)?

    init(
        queue: DispatchQueue,
        coreData: CoreDataService,
        tempId: TempIdService
    ) {
        self.queue = queue
        self.peripheralManager = nil
        self.centralManager = nil
        self.coreData = coreData
        self.tempId = tempId
        self.traceData = [:]
    }

    func setupBluetooth() {
        guard centralManager == nil && peripheralManager == nil else {
            // Already setup
            return
        }
        centralManager = CentralManager(queue: queue, services: [.trace])
        centralManager?.centralDidUpdateStateCallback = centralDidUpdateStateCallback

        let tracerService = CBMutableService(type: Service.trace.toCBUUID(), primary: true)
        let characteristic = CBMutableCharacteristic(type: Characteristic.contact.toCBUUID(), properties: [.read, .write, .writeWithoutResponse], value: nil, permissions: [.readable, .writeable])
        tracerService.characteristics = [characteristic]

        peripheralManager = PeripheralManager(peripheralName: "mamori-i", queue: queue, services: [tracerService])

        _ = peripheralManager?
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
            .onWrite { [unowned self] central, ch, data in
                switch ch {
                case .contact:
                    guard let writeData = WriteData(from: data) else {
                        let str = String(data: data, encoding: .utf8)
                        log("failed to deserialize data=\(String(describing: str))")
                        return false
                    }
                    let record = TraceDataRecord(from: writeData)
                    if self.shouldSave(record: record, about: central.identifier) {
                        log("save: \(record.tempId ?? "nil")")
                        self.coreData.save(traceDataRecord: record)
                        self.traceData[central.identifier] = record
                    }

                    #if DEBUG
                    debugNotify(message: "written=\(writeData.i)")
                    #endif

                    return true
                }
            }

        // Commands and callbacks should happen in this order
        _ = centralManager?
            .didDiscoverTxPower { [unowned self] uuid, txPower in
                var record = self.traceData[uuid] ?? TraceDataRecord()
                record.txPower = txPower
                self.traceData[uuid] = record
            }
            .appendCommand(
                command: .readRSSI
            )
            .didReadRSSI { [unowned self] peripheral, RSSI, error in
                log("peripheral=\(peripheral.shortId), RSSI=\(RSSI), error=\(String(describing: error))")

                guard error == nil else {
                    self.centralManager?.disconnect(peripheral)
                    return
                }
                var record = self.traceData[peripheral.id] ?? TraceDataRecord()
                if record.rssi == nil || (record.rssi! < RSSI.doubleValue) {
                    record.rssi = RSSI.doubleValue
                    self.traceData[peripheral.id] = record
                }
            }
            .appendCommand(
                command: .write(to: .contact, value: { [unowned self] peripheral in
                    let record = self.traceData[peripheral.id] ?? TraceDataRecord()
                    guard let userId = self.tempId.currentTempId ?? self.tempId.latestTempId else {
                        return nil
                    }

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
                    self.centralManager?.disconnect(peripheral)
                    return
                }

                guard let readData = ReadData(from: data!) else {
                    self.centralManager?.disconnect(peripheral)
                    return
                }
                var record = self.traceData[peripheral.id] ?? TraceDataRecord()
                record.tempId = readData.i
                record.timestamp = Date()

                if self.shouldSave(record: record, about: peripheral.id) {
                    log("save: \(record.tempId ?? "nil")")
                    self.coreData.save(traceDataRecord: record)
                    self.traceData[peripheral.id] = record
                }

                #if DEBUG
                debugNotify(message: "read=\(readData.i)")
                #endif
            }
            .appendCommand(
                command: .cancel(callback: { [unowned self] peripheral in
                    self.centralManager?.disconnect(peripheral)
                })
            )
    }

    func turnOn() {
        setupBluetooth()
        peripheralManager?.turnOn()
        centralManager?.turnOn()
    }

    func turnOff() {
        peripheralManager?.turnOff()
        centralManager?.turnOff()
        timerForScanning?.invalidate()
    }

    // shouldSave throttles the records and saves a new record only after 30seconds has passed since the last record from the same peer, identified by the UUID.
    // Caller should update the timestamp only when shouldSave returns true.
    // record parameter should include a non nil timestamp.
    func shouldSave(record: TraceDataRecord, about peerUUID: UUID) -> Bool {
        guard let lastRecord = traceData[peerUUID] else {
            return true
        }
        guard lastRecord.timestamp != nil else {
            return true
        }
        guard record.timestamp != nil else {
            // warning, a record without a timestamp will not be saved.
            return false
        }
        if record.timestamp!.timeIntervalSince(lastRecord.timestamp!) > traceDataRecordThrottleInterval {
            return true
        }
        return false
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
        guard centralManager != nil else {
            return false
        }
        switch centralManager!.getState() {
        case .poweredOff:
            log("[BLEService] Bluetooth is off")
        case .resetting:
            log("[BLEService] Resetting State")
        case .unauthorized:
            log("[BLEService] Unauth State")
        case .unknown:
            log("[BLEService] Unknown State")
        case .unsupported:
            centralManager!.turnOn()
            log("[BLEService] Unsupported State")
        default:
            log("[BLEService] Bluetooth is on")
        }
        return centralManager!.getState() == CBManagerState.poweredOn
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

                    self?.queue.async {
                        self?.traceData = [:]
                    }
                    self?.centralManager?.restartScan()
                }
                self.timerForScanning?.fire()
            }
        default:
            timerForScanning?.invalidate()
        }
    }
}

#if DEBUG
func debugNotify(message: String) {
    let content = UNMutableNotificationContent()
    content.title = message
    let notification = UNNotificationRequest(identifier: NSUUID().uuidString, content: content, trigger: nil)
    UNUserNotificationCenter.current().add(notification) { er in
        if er != nil {
            log("notification error: \(er!)")
        }
    }
}
#endif
