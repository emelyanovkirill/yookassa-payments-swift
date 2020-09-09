final class YandexAuthInteractor {

    // VIPER module properties

    weak var output: YandexAuthInteractorOutput?

    private let authorizationService: AuthorizationProcessing
    private let analyticsService: AnalyticsProcessing
    private let paymentService: PaymentProcessing

    // MARK: - Data properties

    private let clientApplicationKey: String
    private let gatewayId: String?
    private let amount: Amount
    private let getSavePaymentMethod: Bool?

    init(authorizationService: AuthorizationProcessing,
         analyticsService: AnalyticsProcessing,
         paymentService: PaymentProcessing,
         clientApplicationKey: String,
         gatewayId: String?,
         amount: Amount,
         getSavePaymentMethod: Bool?) {
        self.authorizationService = authorizationService
        self.analyticsService = analyticsService
        self.paymentService = paymentService
        self.clientApplicationKey = clientApplicationKey
        self.gatewayId = gatewayId
        self.amount = amount
        self.getSavePaymentMethod = getSavePaymentMethod
    }
}

// MARK: - YandexAuthInteractorInput

extension YandexAuthInteractor: YandexAuthInteractorInput {
    func fetchYamoneyPaymentMethods(
        moneyCenterAuthToken: String
    ) {
        authorizationService.setMoneyCenterAuthToken(moneyCenterAuthToken)

        let paymentMethods = paymentService.fetchPaymentOptions(
            clientApplicationKey: clientApplicationKey,
            // TODO: MOC-1013 (Change passportToken to moneyCenterAuthToken)
            passportToken: moneyCenterAuthToken,
            gatewayId: gatewayId,
            amount: amount.value.description,
            currency: amount.currency.rawValue,
            getSavePaymentMethod: getSavePaymentMethod
        )

        let yamoneyPaymentMethods = paymentMethods.map { $0.filter { $0.paymentMethodType == .yandexMoney } }

        guard let output = output else { return }

        yamoneyPaymentMethods.done(output.didFetchYamoneyPaymentMethods)
        yamoneyPaymentMethods.fail(output.didFetchYamoneyPaymentMethods)
    }

    func trackEvent(_ event: AnalyticsEvent) {
        analyticsService.trackEvent(event)
    }
}
