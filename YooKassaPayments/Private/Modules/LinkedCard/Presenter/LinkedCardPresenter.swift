import YooKassaPaymentsApi

final class LinkedCardPresenter {
    
    // MARK: - VIPER

    var interactor: LinkedCardInteractorInput!
    var router: LinkedCardRouterInput!
    
    weak var view: LinkedCardViewInput?
    weak var moduleOutput: LinkedCardModuleOutput?
    
    // MARK: - Init data
    
    private let cardService: CardService
    private let paymentMethodViewModelFactory: PaymentMethodViewModelFactory
    
    private let clientApplicationKey: String
    private let testModeSettings: TestModeSettings?
    private let isLoggingEnabled: Bool
    private let moneyAuthClientId: String?
    
    private let shopName: String
    private let purchaseDescription: String
    private let price: PriceViewModel
    private let fee: PriceViewModel?
    private let paymentOption: PaymentInstrumentYooMoneyLinkedBankCard
    private let termsOfService: TermsOfService
    private let returnUrl: String?
    private let tmxSessionId: String?
    private var initialSavePaymentMethod: Bool

    // MARK: - Init

    init(
        cardService: CardService,
        paymentMethodViewModelFactory: PaymentMethodViewModelFactory,
        clientApplicationKey: String,
        testModeSettings: TestModeSettings?,
        isLoggingEnabled: Bool,
        moneyAuthClientId: String?,
        shopName: String,
        purchaseDescription: String,
        price: PriceViewModel,
        fee: PriceViewModel?,
        paymentOption: PaymentInstrumentYooMoneyLinkedBankCard,
        termsOfService: TermsOfService,
        returnUrl: String?,
        tmxSessionId: String?,
        initialSavePaymentMethod: Bool
    ) {
        self.cardService = cardService
        self.paymentMethodViewModelFactory = paymentMethodViewModelFactory
        
        self.clientApplicationKey = clientApplicationKey
        self.testModeSettings = testModeSettings
        self.isLoggingEnabled = isLoggingEnabled
        self.moneyAuthClientId = moneyAuthClientId
        
        self.shopName = shopName
        self.purchaseDescription = purchaseDescription
        self.price = price
        self.fee = fee
        self.paymentOption = paymentOption
        self.termsOfService = termsOfService
        self.returnUrl = returnUrl
        self.tmxSessionId = tmxSessionId
        self.initialSavePaymentMethod = initialSavePaymentMethod
    }
    
    // MARK: - Properties
    
    private var csc: String?
    private var isReusableToken = true
}

// MARK: - LinkedCardViewOutput

extension LinkedCardPresenter: LinkedCardViewOutput {
    func setupView() {
        guard let view = view else { return }
        
        view.setupTitle(paymentOption.cardName)
        
        let cardMask =
            paymentMethodViewModelFactory.replaceBullets(paymentOption.cardMask)
        let cardLogo =
            paymentMethodViewModelFactory.makePaymentMethodViewModelImage(paymentOption)
        
        let viewModel = LinkedCardViewModel(
            shopName: shopName,
            description: purchaseDescription,
            price: price,
            fee: fee,
            cardMask: formattingCardMask(cardMask),
            cardLogo: cardLogo,
            terms: termsOfService
        )
        view.setupViewModel(viewModel)
        
        view.setConfirmButtonEnabled(false)
        
        if !interactor.hasReusableWalletToken() {
            view.setSaveAuthInAppSwitchItemView()
        }
        
        DispatchQueue.global().async { [weak self] in
            guard let self = self,
                  let interactor = self.interactor else { return }
            interactor.trackEvent(.screenLinkedCardForm)
        }
    }
    
    func didSetCsc(
        _ csc: String
    ) {
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let self = self else { return }
            self.csc = csc
            do {
                try self.cardService.validate(csc: csc)
            } catch {
                if let error = error as? CardService.ValidationError {
                    DispatchQueue.main.async { [weak self] in
                        guard let view = self?.view else { return }
                        view.setConfirmButtonEnabled(false)
                    }
                    return
                }
            }
            DispatchQueue.main.async { [weak self] in
                guard let view = self?.view else { return }
                view.setConfirmButtonEnabled(true)
            }
        }
    }
    
    func didTapActionButton() {
        view?.endEditing(true)
        view?.showActivity()
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            if self.interactor.hasReusableWalletToken() {
                self.tokenize()
            } else {
                self.interactor.loginInWallet(
                    amount: self.paymentOption.charge.plain,
                    reusableToken: self.isReusableToken,
                    tmxSessionId: self.tmxSessionId
                )
            }
        }
    }
    
    func didTapTermsOfService(_ url: URL) {
        router.presentTermsOfServiceModule(url)
    }
    
    func didChangeSaveAuthInAppState(
        _ state: Bool
    ) {
        isReusableToken = state
    }
    
    func endEditing() {
        guard let csc = csc else {
            view?.setCardErrorState(true)
            return
        }
        
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let self = self else { return }
            do {
                try self.cardService.validate(csc: csc)
            } catch {
                if let error = error as? CardService.ValidationError {
                    DispatchQueue.main.async { [weak self] in
                        guard let view = self?.view else { return }
                        view.setCardErrorState(true)
                    }
                    return
                }
            }
            DispatchQueue.main.async { [weak self] in
                guard let view = self?.view else { return }
                view.setCardErrorState(false)
            }
        }
    }
}

// MARK: - ActionTitleTextDialogDelegate

extension LinkedCardPresenter: ActionTitleTextDialogDelegate {
    func didPressButton(
        in actionTitleTextDialog: ActionTitleTextDialog
    ) {
        guard let view = view else { return }
        view.hidePlaceholder()
        view.showActivity()
        
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            self.tokenize()
        }
    }
}

// MARK: - LinkedCardInteractorOutput

extension LinkedCardPresenter: LinkedCardInteractorOutput {
    func didLoginInWallet(
        _ response: WalletLoginResponse
    ) {
        switch response {
        case .authorized:
            tokenize()
        case let .notAuthorized(
                authTypeState: authTypeState,
                processId: processId,
                authContextId: authContextId
        ):
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.view?.hideActivity()
                
                let inputData = PaymentAuthorizationModuleInputData(
                    clientApplicationKey: self.clientApplicationKey,
                    testModeSettings: self.testModeSettings,
                    isLoggingEnabled: self.isLoggingEnabled,
                    moneyAuthClientId: self.moneyAuthClientId,
                    authContextId: authContextId,
                    processId: processId,
                    tokenizeScheme: .linkedCard,
                    authTypeState: authTypeState
                )
                self.router.presentPaymentAuthorizationModule(
                    inputData: inputData,
                    moduleOutput: self
                )
            }
        }
    }
    
    func failLoginInWallet(
        _ error: Error
    ) {
        DispatchQueue.main.async { [weak self] in
            guard let view = self?.view else { return }
            view.hideActivity()
            
            let message = makeMessage(error)
            view.presentError(with: message)

            DispatchQueue.global().async { [weak self] in
                guard let self = self, let interactor = self.interactor else { return }
                let (authType, _) = interactor.makeTypeAnalyticsParameters()
                interactor.trackEvent(.screenError(authType: authType, scheme: .linkedCard))
            }
        }
    }
    
    func didTokenizeData(_ token: Tokens) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self,
                  let view = self.view else { return }
            view.hideActivity()
            self.moduleOutput?.tokenizationModule(
                self,
                didTokenize: token,
                paymentMethodType: self.paymentOption.paymentMethodType.plain
            )

            DispatchQueue.global().async { [weak self] in
                guard let self = self, let interactor = self.interactor else { return }
                let type = interactor.makeTypeAnalyticsParameters()
                let event: AnalyticsEvent = .actionTokenize(
                    scheme: .linkedCard,
                    authType: type.authType,
                    tokenType: type.tokenType
                )
                interactor.trackEvent(event)
            }
        }
    }

    func failTokenizeData(_ error: Error) {
        let message = makeMessage(error)
        
        DispatchQueue.main.async { [weak self] in
            guard let view = self?.view else { return }
            view.hideActivity()
            view.showPlaceholder(with: message)
        }
    }
    
    private func tokenize() {
        guard let csc = csc else { return }
        
        interactor.tokenize(
            id: paymentOption.cardId,
            csc: csc,
            confirmation: Confirmation(type: .redirect, returnUrl: returnUrl),
            savePaymentMethod: initialSavePaymentMethod,
            paymentMethodType: paymentOption.paymentMethodType.plain,
            amount: paymentOption.charge.plain,
            tmxSessionId: tmxSessionId
        )

        interactor.trackEvent(.actionPaymentAuthorization(.success))
    }
}

// MARK: - PaymentAuthorizationModuleOutput

extension LinkedCardPresenter: PaymentAuthorizationModuleOutput {
    func didCheckUserAnswer(
        _ module: PaymentAuthorizationModuleInput,
        response: WalletLoginResponse
    ) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.router.closePaymentAuthorization()
            self.view?.showActivity()
            self.didLoginInWallet(response)
        }
    }
}

// MARK: - LinkedCardModuleInput

extension LinkedCardPresenter: LinkedCardModuleInput {}

// MARK: - Make message from Error

private func makeMessage(_ error: Error) -> String {
    let message: String

    switch error {
    case let error as PresentableError:
        message = error.message
    default:
        message = §CommonLocalized.Error.unknown
    }

    return message
}

private func formattingCardMask(_ string: String) -> String {
    return string.splitEvery(4, separator: " ")
}
