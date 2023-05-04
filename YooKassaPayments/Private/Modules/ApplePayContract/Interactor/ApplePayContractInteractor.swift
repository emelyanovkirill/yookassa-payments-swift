final class ApplePayContractInteractor {

    // MARK: - VIPER

    weak var output: ApplePayContractInteractorOutput?

    // MARK: - Init data

    private let paymentService: PaymentService
    private let analyticsService: AnalyticsTracking
    private let sessionProfiler: SessionProfiler
    private let authorizationService: AuthorizationService

    private let clientApplicationKey: String
    private let customerId: String?

    // MARK: - Init

    init(
        paymentService: PaymentService,
        analyticsService: AnalyticsTracking,
        authorizationService: AuthorizationService,
        sessionProfiler: SessionProfiler,
        clientApplicationKey: String,
        customerId: String?
    ) {
        self.paymentService = paymentService
        self.analyticsService = analyticsService
        self.authorizationService = authorizationService
        self.sessionProfiler = sessionProfiler

        self.clientApplicationKey = clientApplicationKey
        self.customerId = customerId
    }
}

// MARK: - ApplePayContractInteractorInput

extension ApplePayContractInteractor: ApplePayContractInteractorInput {
    func track(event: AnalyticsEvent) {
        analyticsService.track(event: event)
    }

    func analyticsAuthType() -> AnalyticsEvent.AuthType {
        authorizationService.analyticsAuthType()
    }

    func tokenize(
        paymentData: String,
        savePaymentMethod: Bool,
        amount: MonetaryAmount
    ) {
        sessionProfiler.profileApp { [weak self] result in
            guard let self = self,
                  let output = self.output else { return }

            switch result {
            case .right(let profiledSessionId):
                self.tokenizeApplePayWithTMXSessionId(
                    paymentData: paymentData,
                    savePaymentMethod: savePaymentMethod,
                    amount: amount,
                    tmxSessionId: profiledSessionId
                )

            case .left(let error):
                let mappedError = ErrorMapper.mapPaymentError(error)
                output.failTokenize(mappedError)
            }
        }
    }

    private func tokenizeApplePayWithTMXSessionId(
        paymentData: String,
        savePaymentMethod: Bool,
        amount: MonetaryAmount,
        tmxSessionId: String
    ) {
        guard let output = output else { return }

        let completion: (Result<Tokens, Error>) -> Void = { result in
            switch result {
            case let .success(data):
                output.didTokenize(data)
            case let .failure(error):
                let mappedError = ErrorMapper.mapPaymentError(error)
                output.failTokenize(mappedError)
            }
        }

        paymentService.tokenizeApplePay(
            clientApplicationKey: clientApplicationKey,
            paymentData: paymentData,
            savePaymentMethod: savePaymentMethod,
            amount: amount,
            tmxSessionId: tmxSessionId,
            customerId: customerId,
            completion: completion
        )
    }
}
