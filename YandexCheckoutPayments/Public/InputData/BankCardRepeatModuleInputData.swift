// Input data for repeat bank card tokenization flow.
public struct BankCardRepeatModuleInputData {

    /// Client application key.
    let clientApplicationKey: String

    /// Name of shop.
    let shopName: String

    /// Purchase description.
    let purchaseDescription: String

    /// The ID of the saved payment method.
    let paymentMethodId: String

    /// Amount of payment.
    let amount: Amount

    /// Test mode settings.
    let testModeSettings: TestModeSettings?

    /// Enable logging
    let isLoggingEnabled: Bool

    /// Creates instance of `BankCardRepeatModuleInputData`.
    ///
    /// - Parameters:
    ///   - clientApplicationKey: Client application key.
    ///   - shopName: Name of shop.
    ///   - purchaseDescription: Purchase description.
    ///   - paymentMethodId: The ID of the saved payment method.
    ///   - amount: Amount of payment.
    ///   - testModeSettings: Test mode settings.
    ///   - isLoggingEnabled: Enable logging
    ///
    /// - Returns: Instance of `BankCardRepeatModuleInputData`.
    public init(
        clientApplicationKey: String,
        shopName: String,
        purchaseDescription: String,
        paymentMethodId: String,
        amount: Amount,
        testModeSettings: TestModeSettings? = nil,
        isLoggingEnabled: Bool = false
    ) {
        self.clientApplicationKey = (clientApplicationKey + ":").base64Encoded()
        self.shopName = shopName
        self.purchaseDescription = purchaseDescription
        self.paymentMethodId = paymentMethodId
        self.amount = amount
        self.testModeSettings = testModeSettings
        self.isLoggingEnabled = isLoggingEnabled
    }
}
