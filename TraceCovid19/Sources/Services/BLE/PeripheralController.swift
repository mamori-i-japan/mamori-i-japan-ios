//
//  PeripheralController.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/10.
//

import Foundation
import CoreBluetooth

struct PeripheralCharacteristicsDataV2: Codable {
//    var mp: String // phone model of peripheral
    var i: String // tempID
//    var o: String // organisation
//    var v: Int // protocol version
}

final class PeripheralController: NSObject {
    enum PeripheralError: Error {
        case peripheralAlreadyOn
        case peripheralAlreadyOff
    }

    var didUpdateState: ((String) -> Void)?

    private let restoreIdentifierKey = "com.decurret.TraceCovid19JP" // TODO: レストアキー
    private let peripheralName: String

    private var characteristicDataV2: PeripheralCharacteristicsDataV2

    private var peripheral: CBPeripheralManager!

    private let queue: DispatchQueue
    private let tempId: TempIdService
    private let coreData: CoreDataService

    // Protocol v2 - CharacteristicServiceIDv2
//    private lazy var readableCharacteristicV2 = CBMutableCharacteristic(type: BluetraceConfig.CharacteristicServiceIDv2, properties: [.read, .write, .writeWithoutResponse], value: nil, permissions: [.readable, .writeable])
    private lazy var readableCharacteristicV2 = CBMutableCharacteristic(type: BluetraceConfig.characteristicServiceID, properties: [.read], value: nil, permissions: [.readable])

    init(peripheralName: String, queue: DispatchQueue, tempId: TempIdService, coreData: CoreDataService) {
        print("[PC] init")
        self.queue = queue
        self.peripheralName = peripheralName
        self.tempId = tempId
        self.coreData = coreData

        self.characteristicDataV2 = PeripheralCharacteristicsDataV2(
//            mp: DeviceUtility.machineName(),
            i: BluetraceConfig.initialMsg
//            o: BluetraceConfig.OrgID,
//            v: BluetraceConfig.ProtocolVersion
        )

        super.init()
    }

    func turnOn() {
        guard peripheral == nil else {
            return
        }
        peripheral = CBPeripheralManager(delegate: self, queue: self.queue, options: [CBPeripheralManagerOptionRestoreIdentifierKey: restoreIdentifierKey])
    }

    func turnOff() {
        guard peripheral != nil else {
            return
        }
        peripheral.stopAdvertising()
        peripheral = nil
    }

    func getState() -> CBManagerState {
        return peripheral.state
    }
}

extension PeripheralController: CBPeripheralManagerDelegate {
    func peripheralManager(_ peripheral: CBPeripheralManager, willRestoreState dict: [String: Any]) {
        print("[PC] willRestoreState")
    }

    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        print("[PC] peripheralManagerDidUpdateState. Current state: \(peripheral.state.toString)")
        didUpdateState?(peripheral.state.toString)
        guard peripheral.state == .poweredOn else { return }
        let advertisementData: [String: Any] = [
            CBAdvertisementDataLocalNameKey: peripheralName,
            CBAdvertisementDataServiceUUIDsKey: [BluetraceConfig.bluetoothServiceID]
        ]

        let tracerService = CBMutableService(type: BluetraceConfig.bluetoothServiceID, primary: true)

        tracerService.characteristics = [readableCharacteristicV2]

        peripheral.removeAllServices()

        peripheral.add(tracerService)
        peripheral.startAdvertising(advertisementData)
    }

    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        print("[PC] didReceiveRead \(["request": request] as AnyObject)")

        // NOTE: TempIDの読み込み
        guard let userId = tempId.currentTempId ?? tempId.latestTempId else {
            print("[PC] not found temp user id on CoreData")
            peripheral.respond(to: request, withResult: .unlikelyError)
            return
        }

        characteristicDataV2.i = userId.tempId

        V2Peripheral.shared.prepareReadRequestData(characteristicDataV2: characteristicDataV2) { payload in
            if let payload = payload {
                print("[PC] Success - getting payload")
                request.value = payload
                peripheral.respond(to: request, withResult: .success)
            } else {
                print("[PC] Error - getting payload")
                peripheral.respond(to: request, withResult: .unlikelyError)
            }
        }
    }

    // NOTE: writeは対応しない
//    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
//        let debugLogs = [
//            "requests": requests as AnyObject,
//            "reqValue": String(data: requests[0].value!, encoding: .utf8) ?? "<nil>"
//        ] as AnyObject
//        print("[PC] didReceiveWrite \(debugLogs)")
//        for request in requests {
//            if let receivedCharacteristicValue = request.value {
//                print("[PC] didReceiveWrite value: \(receivedCharacteristicValue)")
//                guard let encounter = V2Peripheral.shared.processWriteRequestDataReceived(dataWritten: receivedCharacteristicValue) else { return }
//                print("[PC] receive encounter: \(encounter)")
//                // NOTE: Peripheral側での保存はやめる
////                print("[PC] save: \(encounter.msg ?? "nil")")
////                coreData.save(encounterRecord: encounter)
//            }
//        }
//        peripheral.respond(to: requests[0], withResult: .success)
//    }
}

class V2Peripheral {
    static let shared = V2Peripheral()

    func prepareReadRequestData(characteristicDataV2: PeripheralCharacteristicsDataV2, onComplete: @escaping (Data?) -> Void) {
        do {
            let data = try JSONEncoder().encode(characteristicDataV2)
            onComplete(data)
        } catch {
            print("[P] Error: \(error). characteristic is \(characteristicDataV2)")
        }
    }

//    func processWriteRequestDataReceived(dataWritten: Data) -> TraceDataRecord? {
//        do {
//            let dataFromCentral = try JSONDecoder().decode(CentralWriteDataV2.self, from: dataWritten)
//            let data = TraceDataRecord(from: dataFromCentral)
//            return data
//        } catch {
//            print("[P] Error: \(error). characteristicValue is \(dataWritten)")
//        }
//        return nil
//    }
}
