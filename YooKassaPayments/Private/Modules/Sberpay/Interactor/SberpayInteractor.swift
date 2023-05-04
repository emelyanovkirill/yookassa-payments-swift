final class SberpayInteractor {

    // MARK: - VIPER

    weak var output: SberpayInteractorOutput?

    // MARK: - Init

    private let authService: AuthorizationService
    private let paymentService: PaymentService
    private let analyticsService: AnalyticsTracking
    private let clientApplicationKey: String
    private let amount: MonetaryAmount
    private let returnUrl: String
    private let customerId: String?

    init(
        authService: AuthorizationService,
        paymentService: PaymentService,
        analyticsService: AnalyticsTracking,
        clientApplicationKey: String,
        amount: MonetaryAmount,
        returnUrl: String,
        customerId: String?
    ) {
        self.authService = authService
        self.paymentService = paymentService
        self.analyticsService = analyticsService
        self.clientApplicationKey = clientApplicationKey
        self.amount = amount
        self.returnUrl = returnUrl
        self.customerId = customerId
    }
}

// MARK: - SberpayInteractorInput

extension SberpayInteractor: SberpayInteractorInput {
    func tokenizeSberpay(savePaymentMethod: Bool) {
        let confirmation = Confirmation(
            type: .mobileApplication,
            returnUrl: self.returnUrl
        )
        self.paymentService.tokenizeSberpay(
            clientApplicationKey: self.clientApplicationKey,
            confirmation: confirmation,
            savePaymentMethod: savePaymentMethod,
            amount: self.amount,
            tmxSessionId: Self.Constants.sberProfiledSessionId,
            customerId: self.customerId
        ) { [weak self] result in
            switch result {
            case .success(let data):
                self?.output?.didTokenize(data)
            case .failure(let error):
                let mappedError = ErrorMapper.mapPaymentError(error)
                self?.output?.didFailTokenize(mappedError)
            }
        }
    }

    func track(event: AnalyticsEvent) {
        analyticsService.track(event: event)
    }

    func analyticsAuthType() -> AnalyticsEvent.AuthType {
        authService.analyticsAuthType()
    }
}

// MARK: - Constants

private extension SberpayInteractor {
    enum Constants {
        static let sberProfiledSessionId = "profilingSessionId"
    }
}
