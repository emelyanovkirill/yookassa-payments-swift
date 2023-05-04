import FunctionalSwift

public enum SessionProfilerError: Error {
    case connectionFail
    case invalidConfiguration
    case internalError
    case interrupted
}

public struct ProfiledSessionParams {
    let uid: String?
    let cardHash: String?
}

public protocol SessionProfiler: AnyObject {
    func profileApp(completion: @escaping (Result<String>) -> Void)
    func profileApp(
        eventType: EventType?,
        completion: @escaping (Result<String>) -> Void
    )
    func stop()
}

extension SessionProfiler {
    func profileApp() -> Promise<Error, String> {
        Promise { self.profileApp(completion: $0) }
    }

    func profileApp(eventType: EventType?) -> Promise<Error, String> {
        Promise { self.profileApp(eventType: eventType, completion: $0) }
    }
}
