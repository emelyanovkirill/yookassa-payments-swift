import YooMoneyPinning

enum AuthenticationChallengeHandlerFactory {

    static func makeHandler(
        host: String,
        isDevHost: Bool,
        isLoggingEnabled: Bool,
        isAuthenticationChallengeIgnored: Bool
    ) -> YooMoneyPinning.AuthenticationChallengeHandler {
        let logger: YooMoneyPinning.Logger? = isLoggingEnabled ? ApiLogger() : nil
        if isAuthenticationChallengeIgnored {
            return YooMoneyPinning.AuthenticationChallengeHandlerFactory.makeTrustHandler(logger: logger)
        } else {
            return YooMoneyPinning.AuthenticationChallengeHandlerFactory.makeHandler(
                config: YooMoneyPinning.Config(host: host, logger: logger),
                apiEnvironmentProvider: PinningApiEnvironmentProvider(isDevHost: isDevHost)
            )
        }
    }
}
