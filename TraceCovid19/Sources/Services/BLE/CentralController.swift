//
//  CentralController.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/10.
//

import Foundation
import CoreBluetooth

struct CentralWriteDataV2: Codable {
    //    var mc: String // phone model of central
    var rs: Double // rssi
    var i: String // tempID
    //    var o: String // organisation
    //    var v: Int // protocol version
}

final class CentralController: NSObject {
    var centralDidUpdateStateCallback: ((CBManagerState) -> Void)?
    var characteristicDidReadValue: ((TraceDataRecord) -> Void)?

    private let restoreIdentifierKey = "com.decurret.TraceCovid19JP" // TODO: レストアキー
    private var central: CBCentralManager?
    private var recoveredPeripherals: [CBPeripheral] = []
    private var queue: DispatchQueue

    private var discoveredAndroidPeriManufacturerToUUIDMap = [Data: UUID]()
    private var scannedPeripherals = [UUID: (peripheral: CBPeripheral, traceData: TraceDataRecord)]()

    var timerForScanning: Timer?

    private let keychain: KeychainService
    private let coreData: CoreDataService

    init(queue: DispatchQueue, keychain: KeychainService, coreData: CoreDataService) {
        self.queue = queue
        self.keychain = keychain
        self.coreData = coreData
        super.init()
    }

    func turnOn() {
        print("[CC] requested to be turnOn")
        guard central == nil else {
            return
        }
        central = CBCentralManager(delegate: self, queue: self.queue, options: [CBCentralManagerOptionRestoreIdentifierKey: restoreIdentifierKey])
    }

    func turnOff() {
        print("[CC] turnOff")
        guard central != nil else {
            return
        }
        central?.stopScan()
        central = nil
    }

    func getState() -> CBManagerState? {
        return central?.state
    }
}

extension CentralController: CBCentralManagerDelegate {
    func centralManager(_ central: CBCentralManager, willRestoreState dict: [String: Any]) {
        // This code handles iOS background state restoration
        //        print("CC willRestoreState. Central state: \(managerStateToString(central?.state))")
        //        if let peripheralsObject = dict[CBCentralManagerRestoredStatePeripheralsKey] {
        //            let peripherals = peripheralsObject as! `Array`<CBPeripheral>
        //            print("CC restoring \(peripherals.count) peripherals from system.")
        //            for peripheral in peripherals {
        //                recoveredPeripherals.append(peripheral)
        //                peripheral.delegate = self
        //                peripheral.readRSSI()
        //            }
        //        }
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        centralDidUpdateStateCallback?(central.state)
        switch central.state {
        case .poweredOn:
            DispatchQueue.main.async {
                self.timerForScanning = Timer.scheduledTimer(withTimeInterval: TimeInterval(BluetraceConfig.CentralScanInterval), repeats: true) { _ in
                    print("[CC] Starting a scan")
                    self.coreData.saveTraceDataWithCurrentTime(for: .scanningStarted)

                    // For all peripherals that are not disconnected, disconnect them
                    self.scannedPeripherals.forEach { scannedPeri in
                        central.cancelPeripheralConnection(scannedPeri.value.peripheral)
                    }
                    // Clear all peripherals, such that a new scan window can take place
                    self.scannedPeripherals = [UUID: (CBPeripheral, TraceDataRecord)]()
                    self.discoveredAndroidPeriManufacturerToUUIDMap = [Data: UUID]()

                    // Using Service ID
                    central.scanForPeripherals(withServices: [BluetraceConfig.bluetoothServiceID])
                    DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(BluetraceConfig.CentralScanDuration)) {
                        print("[CC] Stopping a scan")
                        central.stopScan()
                        self.coreData.saveTraceDataWithCurrentTime(for: .scanningStopped)
                    }
                }
                self.timerForScanning?.fire()
            }
        default:
            timerForScanning?.invalidate()
        }

        // This code handles iOS background state restoration
        //        for recoveredPeripheral in recoveredPeripherals {
        //            if (!discoveredPeripherals.contains(recoveredPeripheral)) {
        //                discoveredPeripherals.append(recoveredPeripheral)
        //                recoveredPeripheral.delegate = self
        //                handlePeripheralOfUncertainStatus(recoveredPeripheral)
        //            }
        //        }
    }

    func handlePeripheralOfUncertainStatus(_ peripheral: CBPeripheral) {
        // If not connected to Peripheral, attempt connection and exit
        if peripheral.state != .connected {
            print("[CC] handlePeripheralOfUncertainStatus not connected")
            central?.connect(peripheral)
            return
        }
        // If don't know about Peripheral's services, discover services and exit
        if peripheral.services == nil {
            print("[CC] handlePeripheralOfUncertainStatus unknown services")
            peripheral.discoverServices([BluetraceConfig.bluetoothServiceID])
            return
        }
        // If Peripheral's services don't contain targetID, disconnect and remove, then exit.
        // If it does contain targetID, discover characteristics for service
        guard let service = peripheral.services?.first(where: { $0.uuid == BluetraceConfig.bluetoothServiceID }) else {
            print("[CC] handlePeripheralOfUncertainStatus no matching Services")
            central?.cancelPeripheralConnection(peripheral)
            return
        }
        print("[CC] handlePeripheralOfUncertainStatus discoverCharacteristics")
        peripheral.discoverCharacteristics([BluetraceConfig.bluetoothServiceID], for: service)
        // If Peripheral's service's characteristics don't contain targetID, disconnect and remove, then exit.
        // If it does contain targetID, read value for characteristic
        guard let characteristic = service.characteristics?.first(where: { $0.uuid == BluetraceConfig.bluetoothServiceID }) else {
            print("[CC] handlePeripheralOfUncertainStatus no matching Characteristics")
            central?.cancelPeripheralConnection(peripheral)
            return
        }
        print("[CC] handlePeripheralOfUncertainStatus readValue")
        peripheral.readValue(for: characteristic)
        return
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        let debugLogs = [
            "CentralState": central.state.toString,
            "peripheral": peripheral,
            "advertisments": advertisementData as AnyObject
        ] as AnyObject

        print("[CC] \(debugLogs)")

        // iphones will "mask" the peripheral's identifier for android devices, resulting in the same android device being discovered multiple times with different peripheral identifier. Hence android is using CBAdvertisementDataServiceDataKey data for identifying an android pheripheral
        if let manuData = advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data {
            let androidIdentifierData = manuData.subdata(in: 2..<manuData.count)
            if discoveredAndroidPeriManufacturerToUUIDMap.keys.contains(androidIdentifierData) {
                print("[CC] Android Peripheral \(peripheral) has been discovered already in this window, will not attempt to connect to it again")
                return
            } else {
                peripheral.delegate = self
                discoveredAndroidPeriManufacturerToUUIDMap.updateValue(peripheral.identifier, forKey: androidIdentifierData)
                scannedPeripherals.updateValue((peripheral, TraceDataRecord(rssi: RSSI.doubleValue, txPower: advertisementData[CBAdvertisementDataTxPowerLevelKey] as? Double)), forKey: peripheral.identifier)
                central.connect(peripheral)
            }
        } else {
            // Means this is not an android device. We check if the peripheral.identifier exist in the scannedPeripherals
            print("[CC] CBAdvertisementDataManufacturerDataKey Data not found. Peripheral is likely not android")
            if scannedPeripherals[peripheral.identifier] == nil {
                peripheral.delegate = self
                scannedPeripherals.updateValue((peripheral, TraceDataRecord(rssi: RSSI.doubleValue, txPower: advertisementData[CBAdvertisementDataTxPowerLevelKey] as? Double)), forKey: peripheral.identifier)
                central.connect(peripheral)
            } else {
                print("[CC] iOS Peripheral \(peripheral) has been discovered already in this window, will not attempt to connect to it again")
            }
        }
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("[CC] didConnect peripheral peripheralCentral state: \(central.state.toString), Peripheral state: \(peripheral.state.toString)")
        peripheral.delegate = self
        peripheral.discoverServices([BluetraceConfig.bluetoothServiceID])
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("[CC] didDisconnectPeripheral \(peripheral) , \(error != nil ? "error: \(error.debugDescription)" : "" )")
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("[CC] didFailToConnect peripheral \(error != nil ? "error: \(error.debugDescription)" : "" )")
    }
}

extension CentralController: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let err = error {
            print("[CC] error: \(err)")
        }
        guard let service = peripheral.services?.first(where: { $0.uuid == BluetraceConfig.bluetoothServiceID }) else { return }

        peripheral.discoverCharacteristics([BluetraceConfig.characteristicServiceID], for: service)
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let err = error {
            print("[CC] error: \(err)")
        }

        print("[CC] didDiscoverCharacteristicsFor \(service)")

        guard let characteristic = service.characteristics?.first(where: { $0.uuid == BluetraceConfig.characteristicServiceID }) else { return }

        // Read要求
        peripheral.readValue(for: characteristic)

        // NOTE: write要求の処理はしない
        //        if let current = scannedPeripherals[peripheral.identifier] {
        //            // TODO: temp idの取得
        //            let tempId = keychain.uuid!.uuidString
        //            guard let rssi = current.traceData.rssi else {
        //                print("[CC] rssi should be present in \(current.traceData)")
        //                return
        //            }
        //
        //            guard let encodedData = V2Central.shared.prepareWriteRequestData(tempId: tempId, rssi: rssi, txPower: current.traceData.txPower) else {
        //                return
        //            }
        //            print("[CC] write tempId: \(tempId), rssi: \(rssi)")
        //            peripheral.writeValue(encodedData, for: characteristic, type: .withResponse)
        //        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        let debugLogs = [
            "characteristic": characteristic as AnyObject,
            "encounter": scannedPeripherals[peripheral.identifier] as AnyObject
        ] as AnyObject

        print("[CC] didUpdateValueFor \(debugLogs)")
        if error == nil {
            if let scannedPeri = scannedPeripherals[peripheral.identifier],
                let receivedCharacteristicValue = characteristic.value {
                print("[CC] characteristic: \(String(describing: String(data: receivedCharacteristicValue, encoding: .utf8)))")
                guard let traceData = V2Central.shared.processReadRequestDataReceived(scannedPeriData: scannedPeri.traceData, characteristicValue: receivedCharacteristicValue) else {
                    return
                }

                scannedPeripherals.updateValue((scannedPeri.peripheral, traceData), forKey: peripheral.identifier)
                print("[CC] save: \(traceData.tempId ?? "nil")")
                coreData.save(traceDataRecord: traceData)

                // NOTE: readのレスポンスがかえってきたところで接続をキャンセルする
                print("[CC] cancel connection: \(peripheral)")
                central?.cancelPeripheralConnection(peripheral)
            } else {
                print("[CC] Error: scannedPeripherals[peripheral.identifier] is \(String(describing: scannedPeripherals[peripheral.identifier])), characteristic.value is \(String(describing: characteristic.value))")
            }
        } else {
            print("[CC] Error: \(error!)")
        }
    }

    //    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
    //        print("[CC] didWriteValueFor to peripheral: \(peripheral), for characteristics: \(characteristic). \(error != nil ? "error: \(error.debugDescription)" : "" )")
    //        central?.cancelPeripheralConnection(peripheral)
    //    }
}

final class V2Central {
    static let shared = V2Central()

    func prepareWriteRequestData(tempId: String, rssi: Double, txPower: Double?) -> Data? {
        do {
            let dataToWrite = CentralWriteDataV2(
                //                mc: DeviceUtility.machineName(),
                rs: rssi,
                i: tempId
                //                o: BluetraceConfig.OrgID,
                //                v: BluetraceConfig.ProtocolVersion
            )

            let encodedData = try JSONEncoder().encode(dataToWrite)

            return encodedData
        } catch {
            print("[C] Error: \(error)")
        }

        return nil
    }

    func processReadRequestDataReceived(scannedPeriData: TraceDataRecord, characteristicValue: Data) -> TraceDataRecord? {
        do {
            let peripheralCharData = try JSONDecoder().decode(PeripheralCharacteristicsDataV2.self, from: characteristicValue)
            var data = scannedPeriData

            data.tempId = peripheralCharData.i

            data.timestamp = Date() // NOTE: タイムスタンプ更新を追加

            return data
        } catch {
            print("[C] Error: \(error). characteristicValue is \(characteristicValue)")
        }
        return nil
    }
}
