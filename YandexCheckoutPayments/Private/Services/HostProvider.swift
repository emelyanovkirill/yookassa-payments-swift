import YandexCheckoutPaymentsApi
import YandexCheckoutWalletApi
import YandexMoneyCoreApi

final class HostProvider: YandexMoneyCoreApi.HostProvider {

    let settingsStorage: KeyValueStoring

    init(settingStorage: KeyValueStoring) {
        self.settingsStorage = settingStorage
    }

    func host(for key: String) throws -> String {
        let isDevHost: Bool = settingsStorage.getBool(for: Settings.Keys.devHost) ?? false
        let host: String

        if isDevHost,
           let devHost = try makeDevHost(key: key) {
            host = devHost
        } else {
            switch key {
            case YandexCheckoutPaymentsApi.Constants.paymentsApiMethodsKey:
                host = "//payment.yandex.net"
            case YandexCheckoutWalletApi.Constants.walletApiMethodsKey:
                host = "//yoomoney.ru"
            case GlobalConstants.Hosts.moneyAuth:
                host = "//yoomoney.ru"
            default:
                throw HostProviderError.unknownKey(key)
            }
        }

        return host
    }

    private func makeDevHost(key: String) throws -> String? {
        guard let devHosts = HostProvider.hosts else {
            return nil
        }

        let host: String

        switch key {
        case YandexCheckoutWalletApi.Constants.walletApiMethodsKey:
            host = devHosts.wallet
        case YandexCheckoutPaymentsApi.Constants.paymentsApiMethodsKey:
            host = devHosts.payments
        case GlobalConstants.Hosts.moneyAuth:
            host = devHosts.moneyAuth
        default:
            throw HostProviderError.unknownKey(key)
        }

        return host
    }

    private static var hosts: HostsConfig? = {
        guard let url = Bundle.framework.url(forResource: "Hosts", withExtension: "plist"),
            let hosts = NSDictionary(contentsOf: url) as? [String: Any],
            let walletHost = hosts[Keys.wallet.rawValue] as? String,
            let paymentsHost = hosts[Keys.payments.rawValue] as? String,
            let moneyAuthHost = hosts[Keys.moneyAuth.rawValue] as? String else {
                assertionFailure("Couldn't load Hosts.plist from framework bundle")
                return nil
        }

        return HostsConfig(
            wallet: walletHost,
            payments: paymentsHost,
            moneyAuth: moneyAuthHost
        )
    }()

    private enum Keys: String {
        case wallet
        case payments
        case moneyAuth
    }
}
