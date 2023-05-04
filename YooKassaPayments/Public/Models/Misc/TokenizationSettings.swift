/// Tokenization settings.
public struct TokenizationSettings {

    /// Type of the source of funds for the payment.
    public let paymentMethodTypes: PaymentMethodTypes

    /// Creates instance of `TokenizationSettings`.
    ///
    /// - Parameters:
    ///   - paymentMethodTypes: Type of the source of funds for the payment.
    ///   - showYooKassaLogo: A Boolean value that determines whether YooKassa
    ///                             logo will be displayed on the screen of available payment methods.
    ///
    /// - Returns: Instance of `TokenizationSettings`
    public init(
        paymentMethodTypes: PaymentMethodTypes = .all
    ) {
        self.paymentMethodTypes = paymentMethodTypes
    }
}
