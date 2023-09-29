import YooKassaPaymentsApi

final class ApiKeyProviderImpl: ApiKeyProvider {

    private let clientApplicationKey: String
    private let paymentService: PaymentService

    // MARK: Init

    init(
        clientApplicationKey: String,
        paymentService: PaymentService
    ) {
        self.clientApplicationKey = clientApplicationKey
        self.paymentService = paymentService
    }

    func getSberKey() async throws -> String {
        return try await withCheckedThrowingContinuation { [unowned self] continuation in
            paymentService
                .fetchApiKey(clientApplicationKey: clientApplicationKey)
                .right {
                    continuation.resume(returning: $0)
                }
                .left { error in
                    continuation.resume(throwing: error)
                }
        }
    }

}
