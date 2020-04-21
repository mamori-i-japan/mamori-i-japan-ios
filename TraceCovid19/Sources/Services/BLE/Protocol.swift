import Foundation

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

    func processReadRequestDataReceived(scannedPeriData: TraceDataRecord?, characteristicValue: Data) -> TraceDataRecord? {
        do {
            let peripheralCharData = try JSONDecoder().decode(PeripheralCharacteristicsDataV2.self, from: characteristicValue)
            var data = scannedPeriData ?? TraceDataRecord()

            data.tempId = peripheralCharData.i
            data.timestamp = Date() // NOTE: タイムスタンプ更新を追加

            return data
        } catch {
            print("[C] Error: \(error). characteristicValue is \(characteristicValue)")
        }
        return nil
    }
}

struct CentralWriteDataV2: Codable {
    //    var mc: String // phone model of central
    var rs: Double // rssi
    var i: String // tempID
    //    var o: String // organisation
    //    var v: Int // protocol version
}
