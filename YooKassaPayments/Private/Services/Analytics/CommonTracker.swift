import Foundation
import AppMetricaCore
class CommonTracker: AnalyticsTracking {
    // MARK: - Properties

    private let isLoggingEnabled: Bool

    static let activateOnce: Void = {
#if DEBUG
        let yandexMetricaKey = "fdeb958c-8bfd-4dab-98df-f9be4bdb6646"
#else
        let yandexMetricaKey = "b1ddbdc0-dca6-489c-a205-f71e0158bfcb"
#endif
        if let config = AppMetricaConfiguration(apiKey: yandexMetricaKey) {
            AppMetrica.activate(with: config)
        }
    }()

    init(isLoggingEnabled: Bool) {
        self.isLoggingEnabled = isLoggingEnabled
        CommonTracker.activateOnce
    }

    func track(name: String, parameters: [String: String]?) {
        AppMetrica.reportEvent(name: name, parameters: parameters)

        if isLoggingEnabled {
            #if DEBUG
            let paraString = parameters.map { ", parameters: \($0)" } ?? ""
            print("!YMMYandexMetrica report event. name: \(name)" + paraString)
            #endif
        }
    }

    func track(event: AnalyticsEvent) {
        track(name: event.name, parameters: event.parameters(context: YKSdk.shared.analyticsContext))
    }

    func resume() {
        AppMetrica.resumeSession()
    }

    func pause() {
        AppMetrica.pauseSession()
    }
}
