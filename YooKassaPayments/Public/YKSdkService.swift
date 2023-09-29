import SPaySdk

/// Class for handle open url.
public final class YKSdk {

    /// Input for payment methods module.
    weak var paymentMethodsModuleInput: PaymentMethodsModuleInput?

    /// Output for tokenization module.
    weak var moduleOutput: TokenizationModuleOutput?

    /// Input forsbpt methods module.
    weak var sbpConfirmationModuleInput: SbpConfirmationModuleInput?

    /// Application scheme for returning after opening a deeplink.
    var applicationScheme: String?

    var analyticsTracking: AnalyticsTracking!
    var analyticsContext: AnalyticsEventContext!

    private init() {}

    /// Shared YooKassa sdk service.
    public static let shared = YKSdk()

    /// Open a resource specified by a URL.
    public func handleOpen(url: URL, sourceApplication: String?) -> Bool {

        var deeplink: DeepLink?

        if checkAppScheme(url) {
            deeplink = DeepLinkFactory.makeDeepLink(url: url)
        } else if checkExternalScheme(url) {
            deeplink = .external
        }

        guard let deeplink = deeplink else { return false }

        switch deeplink {
        case .invoicingSberpay:
            analyticsTracking.track(event: .actionSberPayConfirmation(success: true))
            moduleOutput?.didSuccessfullyConfirmation(paymentMethodType: .sberbank)
            moduleOutput?.didFinishConfirmation(paymentMethodType: .sberbank)

        case .spayAuth:
            SPay.getAuthURL(url)

        case .yooMoneyExchange(let cryptogram):
            paymentMethodsModuleInput?.authorizeInYooMoney(with: cryptogram)

        case .nspk:
            sbpConfirmationModuleInput?.checkSbpPaymentStatus()

        case .external:
            break
        }

        return true
    }

    private func checkAppScheme(_ url: URL) -> Bool {
        if let scheme = url.scheme,
           let applicationScheme = applicationScheme,
           "\(scheme)://" == applicationScheme {
            return true
        } else {
            return false
        }
    }

    private func checkExternalScheme(_ url: URL) -> Bool {
        return url.scheme == "sbolidexternallogin" || url.scheme == "sberbankidexternallogin"
    }
}
