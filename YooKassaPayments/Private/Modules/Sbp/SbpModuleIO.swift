import YooKassaPaymentsApi

enum SbpModuleFlow: Int {
    case tokenization
    case confirmation
}

struct SbpModuleInputData {
    let paymentOption: PaymentOption
    let clientApplicationKey: String
    let customerId: String?
    let isLoggingEnabled: Bool
    let testModeSettings: TestModeSettings?
    let tokenizationSettings: TokenizationSettings

    let shopName: String
    let isSafeDeal: Bool
    let purchaseDescription: String
    let priceViewModel: PriceViewModel
    let feeViewModel: PriceViewModel?
    let termsOfService: NSAttributedString
    let returnUrl: String
    let isBackBarButtonHidden: Bool
    let clientSavePaymentMethod: SavePaymentMethod
    let config: Config
}

protocol SbpModuleOutput: AnyObject {
    func sbpModule(
        _ module: SbpModuleInput,
        didTokenize token: Tokens,
        paymentMethodType: PaymentMethodType
    )

    func sbpModule(
        _ module: SbpModuleInput,
        didFinishConfirmation paymentMethodType: PaymentMethodType
    )
}

protocol SbpModuleInput: AnyObject {
    func hideActivity()
    func confirmPayment(clientApplicationKey: String, confirmationUrl: String)
}
