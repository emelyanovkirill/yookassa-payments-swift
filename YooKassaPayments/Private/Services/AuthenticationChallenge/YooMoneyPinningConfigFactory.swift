import YooMoneyPinning

enum YooMoneyPinningConfigFactory {

    static func makeConfig(isLoggingEnabled: Bool) -> YooMoneyPinning.Config {
        let hostProvider = HostProviderAssembly.makeHostProvider()
        let logger: ApiLogger? = isLoggingEnabled ? ApiLogger() : nil
        let host = (try? hostProvider.host(for: GlobalConstants.Hosts.main)) ?? ""
        return YooMoneyPinning.Config(host: host, logger: logger)
    }
}
