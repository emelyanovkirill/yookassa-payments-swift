import YooMoneyCoreApi
import YooMoneyPinning

enum ApiSessionAssembly {

    static func makeApiSession(
        isLoggingEnabled: Bool
    ) -> ApiSession {
        let configuration: URLSessionConfiguration = .default

        if let uint = UserDefaults.standard.value(forKey: "policy_override") as? UInt, let policy = URLRequest.CachePolicy(rawValue: uint) {
            configuration.requestCachePolicy = policy
        }

        configuration.httpAdditionalHeaders = [
            "User-Agent": UserAgentFactory.makeHeaderValue(),
        ]

        if let lang = YKSdk.shared.lang {
            // swiftlint:disable:next force_unwrapping
            configuration.httpAdditionalHeaders!["Accept-Language"] = lang
        }

        let hostProvider = HostProviderAssembly.makeHostProvider()
        let session = ApiSession(
            hostProvider: hostProvider,
            configuration: configuration,
            logger: isLoggingEnabled ? ApiLogger() : nil
        )
        let isDevHost: Bool? = try? KeyValueStoringAssembly
            .makeUserDefaultsStorage()
            .readValue(for: Settings.Keys.devHost)
        let authenticationChallengeIgnored: Bool? = try? KeyValueStoringAssembly
            .makeUserDefaultsStorage()
            .readValue(for: Settings.Keys.authenticationChallengeIgnored)

        let authenticationChallengeHandler = AuthenticationChallengeHandlerFactory.makeHandler(
            host: (try? hostProvider.host(for: GlobalConstants.Hosts.main)) ?? "",
            isDevHost: isDevHost ?? false,
            isLoggingEnabled: isLoggingEnabled,
            isAuthenticationChallengeIgnored: authenticationChallengeIgnored ?? false
        )
        session.taskDidReceiveChallengeWithCompletion = authenticationChallengeHandler.process
        return session
    }
}
