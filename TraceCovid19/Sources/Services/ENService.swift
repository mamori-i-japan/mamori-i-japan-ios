import Foundation
import ExposureNotification

final class ENService: NSObject {
    enum Error: String, Swift.Error {
        case disabled
        case unsupported
        case unauthorized
        case dealloced
    }

    private let queue: DispatchQueue!
    private let traceDataUploadAPI: TraceDataUploadAPI!
    // Has to be re-instantiated after invalidated.
    // https://covid19-static.cdn-apple.com/applications/covid19/current/static/contact-tracing/pdf/ExposureNotification-FrameworkDocumentationv1.2.pdf p8
    // Once invalidate is called, the object cannot be reused. A new object must be created for subsequent
    // use. All strong references are cleared when invalidation completes to break potential retain cycles. You
    // don't need to use weak references within your handlers to avoid retain cycles when using this class.
    private var enManager: Any? // ENManager is available from iOS 13.4
    private var exposureNotificationStatusObservation: NSKeyValueObservation?
    private var exposureNotificationEnabledObservation: NSKeyValueObservation?

    init(
        queue: DispatchQueue,
        traceDataUploadAPI: TraceDataUploadAPI
    ) {
        self.queue = queue
        self.traceDataUploadAPI = traceDataUploadAPI
        super.init()
        setupManager()
    }

    private func setupManager() {
        if #available(iOS 13.4, *) {
            let e = ENManager()
            e.dispatchQueue = queue
            e.invalidationHandler = { [weak self] in
                self?.enManager = nil
            }
            exposureNotificationStatusObservation = e.observe(\ENManager.exposureNotificationStatus) { _, change in
                log("exposureNotificationStatus changed, newValue=\(change.newValue!), oldValue=\(change.oldValue!)")
            }
            exposureNotificationEnabledObservation = e.observe(\ENManager.exposureNotificationEnabled) { _, change in
                log("exposureNotificationEnabled changed, newValue=\(change.newValue!), oldValue=\(change.oldValue!)")
            }
            self.enManager = e
        }
    }

    func turnOn() {
        if enManager == nil {
            setupManager()
        }
        if #available(iOS 13.4, *) {
            guard let e = enManager as? ENManager else { return }

            e.activate { error in
                log("activated, error=\(String(describing: error)), authorizationStatus=\(ENManager.authorizationStatus)")

                e.setExposureNotificationEnabled(true) { error in
                    log("enabled, error=\(String(describing: error)), authorizationStatus=\(ENManager.authorizationStatus)")
                }
            }
        }
    }

    func turnOff() {
        if #available(iOS 13.4, *) {
            (enManager as? ENManager)?.invalidate()
        }
    }

    func upload(completion: @escaping (Result<Void, Error>) -> Void) {
        if #available(iOS 13.4, *) {
            guard let e = enManager as? ENManager else {
                DispatchQueue.main.async {
                    completion(.failure(.disabled))
                }
                return
            }
            e.getDiagnosisKeys { [weak self] _, _ in
                guard let api = self?.traceDataUploadAPI else {
                    DispatchQueue.main.async {
                        completion(.failure(.dealloced))
                    }
                    return
                }
                // TODO
                // api.upload(deepContactUsers: T##[DeepContactUserUploadModel], completionHandler: T##(Result<EmpytResponse, APIRequestError>) -> Void)
            }
        } else {
            DispatchQueue.main.async {
                completion(.failure(.unsupported))
            }
        }
    }

    // For debug use by DebugViewController
    @available(iOS 13.4, *)
    func getDiagnosisKeys(completion: @escaping ENGetDiagnosisKeysHandler) {
        guard let e = enManager as? ENManager else {
            DispatchQueue.main.async {
                completion(nil, Error.disabled)
            }
            return
        }
        e.getDiagnosisKeys { temporaryExposureKeys, error in
            log("temporaryExposureKeys=\(String(describing: temporaryExposureKeys)), error=\(String(describing: error))")
            DispatchQueue.main.async {
                completion(temporaryExposureKeys, error)
            }
        }
    }

    func resetAllData(completion: @escaping (Swift.Error?) -> Void) {
        if #available(iOS 13.4, *) {
            guard let e = enManager as? ENManager else {
                DispatchQueue.main.async {
                    completion(Error.disabled)
                }
                return
            }
            e.resetAllData { error in
                log("error=\(String(describing: error))")
                DispatchQueue.main.async {
                    completion(error)
                }
            }
        } else {
            DispatchQueue.main.async {
                completion(ENService.Error.unsupported)
            }
        }
    }
}

extension ENAuthorizationStatus: CustomStringConvertible {
    public var description: String {
        switch self {
        case .authorized:
            return "authorized"
        case .notAuthorized:
            return "notAuthorized"
        case .restricted:
            return "restricted"
        case .unknown:
            return "unknown"
        @unknown default:
            return "default"
        }
    }
}
