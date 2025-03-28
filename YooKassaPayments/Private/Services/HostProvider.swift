import Foundation
import YooKassaPaymentsApi
import YooKassaWalletApi
import YooMoneyCoreApi

final class HostProvider {

    // MARK: - Init data

    private let settingsStorage: KeyValueStoring
    private let configStorage: KeyValueStoring

    // MARK: - Init

    init(settingStorage: KeyValueStoring, configStorage: KeyValueStoring) {
        self.settingsStorage = settingStorage
        self.configStorage = configStorage
    }
}

// MARK: - YooMoneyCoreApi.HostProvider

extension HostProvider: YooMoneyCoreApi.HostProvider {

    func host(for key: String) throws -> String {
        let isDevHost = (try? settingsStorage.readValue(for: Settings.Keys.devHost)) ?? false
        var host: String

        if isDevHost,
           let devHost = try makeDevHost(key: key) {
            host = devHost
        } else {
            let config: Config = ConfigMediatorImpl.storedConfig(storage: configStorage)
            switch key {
            case YooKassaPaymentsApi.Constants.paymentsApiMethodsKey:
                host = config.yooMoneyApiEndpoint.absoluteString
            case YooKassaWalletApi.Constants.walletApiMethodsKey:
                host = config.yooMoneyPaymentAuthorizationApiEndpoint.absoluteString
            case GlobalConstants.Hosts.moneyAuth:
                if let auth = config.yooMoneyAuthApiEndpoint, !auth.isEmpty {
                    host = auth
                } else {
                    host = "https://yoomoney.ru"
                }
            case GlobalConstants.Hosts.config:
                host = "https://yookassa.ru"
            case GlobalConstants.Hosts.main:
                host = config.yooMoneyApiEndpoint.absoluteString
            default:
                throw HostProviderError.unknownKey(key)
            }

            guard var components = URLComponents(string: host) else { throw HostProviderError.unknownKey(key) }
            components.path = ""

            guard let url = components.url else { throw HostProviderError.unknownKey(key) }
            host = url.absoluteString
        }

        return host
    }

    private func makeDevHost(
        key: String
    ) throws -> String? {
        guard
            let hostname: String = try? settingsStorage.readValue(for: Settings.Keys.devHostname),
            let devHosts = HostProvider.hosts(hostname: hostname)
        else { return nil }

        let host: String

        switch key {
        case YooKassaWalletApi.Constants.walletApiMethodsKey:
            host = devHosts.wallet
        case YooKassaPaymentsApi.Constants.paymentsApiMethodsKey:
            host = devHosts.payments
        case GlobalConstants.Hosts.moneyAuth:
            host = devHosts.moneyAuth
        case GlobalConstants.Hosts.config:
            host = devHosts.config
        case GlobalConstants.Hosts.main:
            host = devHosts.payments
        default:
            throw HostProviderError.unknownKey(key)
        }

        guard var components = URLComponents(string: host) else { throw HostProviderError.unknownKey(key) }
        components.path = ""

        guard let url = components.url else { throw HostProviderError.unknownKey(key) }
        return url.absoluteString
    }

    private static func hosts(hostname: String) -> HostsConfig? {
        guard
            let url = Bundle.framework.url(forResource: "Hosts", withExtension: "plist"),
            let schemes = NSDictionary(contentsOf: url) as? [String: Any],
            let hosts = schemes[hostname] as? [String: Any],
            let walletHost = hosts[Keys.wallet.rawValue] as? String,
            let paymentsHost = hosts[Keys.payments.rawValue] as? String,
            let moneyAuthHost = hosts[Keys.moneyAuth.rawValue] as? String,
            let config = hosts[Keys.config.rawValue] as? String
        else {
            assertionFailure("Couldn't load Hosts.plist from framework bundle")
            return nil
        }

        return HostsConfig(
            wallet: walletHost,
            payments: paymentsHost,
            moneyAuth: moneyAuthHost,
            config: config
        )
    }

    private enum Keys: String {
        case wallet
        case payments
        case moneyAuth
        case config
    }
}
