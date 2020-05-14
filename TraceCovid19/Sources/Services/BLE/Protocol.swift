import Foundation

struct ReadData: Codable {
    var i: String // tempID

    init(tempID: String) {
        i = tempID
    }
    init?(from data: Data) {
        do {
            self = try JSONDecoder().decode(ReadData.self, from: data)
        } catch {
            log("[P] Error: \(error). characteristicValue is \(data)")
            return nil
        }
    }
    var data: Data? {
        do {
            return try JSONEncoder().encode(self)
        } catch {
            log("[P] Error: \(error). data is \(self)")
        }
        return nil
    }
}

struct WriteData: Codable {
    var rs: Double // rssi
    var i: String // tempID

    init(RSSI: Double, tempID: String) {
        rs = RSSI
        i = tempID
    }
    init?(from data: Data) {
        do {
            self = try JSONDecoder().decode(WriteData.self, from: data)
        } catch {
            log("[P] Error: \(error). characteristicValue is \(data)")
            return nil
        }
    }
    var data: Data? {
        do {
            return try JSONEncoder().encode(self)
        } catch {
            log("[P] Error: \(error). data is \(self)")
        }
        return nil
    }
}
