import Foundation

enum ApiKeyProviderFactory {
    static func makeService(_ clientApplicationKey: String) -> ApiKeyProvider {
        let tokenizationSettings = TokenizationSettings(paymentMethodTypes: .all)
        let paymentService = PaymentServiceAssembly.makeService(
            tokenizationSettings: tokenizationSettings,
            testModeSettings: nil,
            isLoggingEnabled: true
        )
        return ApiKeyProviderImpl(
            clientApplicationKey: clientApplicationKey,
            paymentService: paymentService
        )
    }
}
