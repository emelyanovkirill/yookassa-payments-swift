final class SbpPresenter {

    // MARK: - VIPER

    weak var moduleOutput: SbpModuleOutput?
    var interactor: SbpInteractorInput!
    var router: SbpRouterInput!

	weak var view: SbpViewInput?

    // MARK: - Init data

    private let shopName: String
    private let purchaseDescription: String
    private let priceViewModel: PriceViewModel
    private let feeViewModel: PriceViewModel?
    private let termsOfService: NSAttributedString
    private let clientSavePaymentMethod: SavePaymentMethod
    private let isSavePaymentMethodAllowed: Bool
    private let isSafeDeal: Bool
    private let isBackBarButtonHidden: Bool
    private let returnUrl: String
    private let config: Config
    private let testModeSettings: TestModeSettings?
    private let isLoggingEnabled: Bool

    private var recurrencySectionSwitchValue: Bool?
    private var clientApplicationKey: String?
    private var confirmationUrl: String?

    private lazy var autopaymentsText: NSAttributedString = {
        return HTMLUtils.highlightHyperlinks(html: Localized.autopaymentsTitle)
    }()

    init(
        shopName: String,
        purchaseDescription: String,
        priceViewModel: PriceViewModel,
        feeViewModel: PriceViewModel?,
        termsOfService: NSAttributedString,
        clientSavePaymentMethod: SavePaymentMethod,
        isSavePaymentMethodAllowed: Bool,
        isSafeDeal: Bool,
        isBackBarButtonHidden: Bool,
        returnUrl: String,
        config: Config,
        isLoggingEnabled: Bool,
        testModeSettings: TestModeSettings?
    ) {
        self.shopName = shopName
        self.purchaseDescription = purchaseDescription
        self.priceViewModel = priceViewModel
        self.feeViewModel = feeViewModel
        self.termsOfService = termsOfService
        self.clientSavePaymentMethod = clientSavePaymentMethod
        self.isSavePaymentMethodAllowed = isSavePaymentMethodAllowed
        self.isSafeDeal = isSafeDeal
        self.isBackBarButtonHidden = isBackBarButtonHidden
        self.returnUrl = returnUrl
        self.config = config
        self.isLoggingEnabled = isLoggingEnabled
        self.testModeSettings = testModeSettings
    }
}

// MARK: - SbpViewOutput

extension SbpPresenter: SbpViewOutput {
	func setupView() {
        guard let view = view else { return }
        let priceValue = makePrice(priceViewModel)

        var feeValue: String?
        if let feeViewModel = feeViewModel {
            feeValue = "\(CommonLocalized.Contract.fee) " + makePrice(feeViewModel)
        }

        let termsOfServiceValue = termsOfService

        var section: PaymentRecurrencyAndDataSavingSection?
        if isSavePaymentMethodAllowed {
            switch clientSavePaymentMethod {
            case .userSelects:
                section = PaymentRecurrencyAndDataSavingSectionFactory.make(
                    mode: .allowRecurring,
                    texts: config.savePaymentMethodOptionTexts,
                    output: self
                )
                recurrencySectionSwitchValue = section?.switchValue
            case .on:
                section = PaymentRecurrencyAndDataSavingSectionFactory.make(
                    mode: .requiredRecurring,
                    texts: config.savePaymentMethodOptionTexts,
                    output: self
                )
                recurrencySectionSwitchValue = true
            case .off:
                section = nil
            }
        }

        let viewModel = SbpViewModel(
            shopName: shopName,
            description: purchaseDescription,
            priceValue: priceValue,
            feeValue: feeValue,
            termsOfService: termsOfServiceValue,
            autopaymentsText: autopaymentsText,
            paymentOptionTitle: config.paymentMethods.first { $0.kind == .sbp }?.title,
            recurrencyAndDataSavingSection: section,
            safeDealText: isSafeDeal ? PaymentMethodResources.Localized.safeDealInfoLink : nil
        )
        view.setViewModel(viewModel)
        view.setBackBarButtonHidden(isBackBarButtonHidden)

        trackScreenPaymentAnalytics()
    }

    func didPressSubmitButton() {
        guard let view = view else { return }
        view.showActivity()
        DispatchQueue.global().async { [weak self] in
            guard let self = self,
                  let interactor = self.interactor else { return }
            interactor.tokenizeSbp(
                savePaymentMethod: self.recurrencySectionSwitchValue ?? false,
                returnUrl: self.returnUrl
            )
        }
    }

    func didPressTermsOfService(_ url: URL) {
        router.showBrowser(url: url)
    }

    func didPressSafeDealInfo(_ url: URL) {
        router.showSafeDealInfo(
            title: PaymentMethodResources.Localized.safeDealInfoTitle,
            body: PaymentMethodResources.Localized.safeDealInfoBody
        )
    }

    func didPressAutopayments(_ url: URL) {
        router.showBrowser(url: url)
    }

    func didPressRepeatTokenezation() {
        guard let view = view else { return }
        view.hidePlaceholder()
        view.showActivity()
        DispatchQueue.global().async { [weak self] in
            guard let self = self, let interactor = self.interactor else { return }
            interactor.track(
                event: .actionTryTokenize(scheme: .sbp, currentAuthType: interactor.analyticsAuthType())
            )
            interactor.tokenizeSbp(
                savePaymentMethod: self.recurrencySectionSwitchValue ?? false,
                returnUrl: self.returnUrl
            )
        }
    }

    func didPressRepeatConfirmation() {
        guard let view = view,
              let clientKey = clientApplicationKey,
              let url = confirmationUrl
        else { return }

        view.hidePlaceholder()
        view.showActivity()

        confirmPayment(
            clientApplicationKey: clientKey,
            confirmationUrl: url
        )
    }
}

// MARK: - PaymentRecurrencyAndDataSavingSectionOutput

extension SbpPresenter: PaymentRecurrencyAndDataSavingSectionOutput {
    func didChangeSwitchValue(newValue: Bool, mode: PaymentRecurrencyAndDataSavingSection.Mode) {
        recurrencySectionSwitchValue = newValue
    }

    func didTapInfoLink(mode: PaymentRecurrencyAndDataSavingSection.Mode) {
        switch mode {
        case .allowRecurring, .requiredRecurring:
            router.showSafeDealInfo(
                title: CommonLocalized.CardSettingsDetails.autopayInfoTitle,
                body: CommonLocalized.CardSettingsDetails.autopayInfoDetails
            )
        case .savePaymentData, .requiredSaveData:
            router.showSafeDealInfo(
                title: CommonLocalized.RecurrencyAndSavePaymentData.saveDataInfoTitle,
                body: CommonLocalized.RecurrencyAndSavePaymentData.saveDataInfoMessage
            )
        case .allowRecurringAndSaveData, .requiredRecurringAndSaveData:
            router.showSafeDealInfo(
                title: CommonLocalized.RecurrencyAndSavePaymentData.saveDataAndAutopaymentsInfoTitle,
                body: CommonLocalized.RecurrencyAndSavePaymentData.saveDataAndAutopaymentsInfoMessage
            )
        default:
        break
        }
    }
}

// MARK: - Private helpers

private extension SbpPresenter {
    func makePrice(_ priceViewModel: PriceViewModel) -> String {
        priceViewModel.integerPart
        + priceViewModel.decimalSeparator
        + priceViewModel.fractionalPart
        + priceViewModel.currency
    }

    func makeErrorText(_ error: Error) -> String {
        let message: String

        switch error {
        case let error as PresentableError:
            message = error.message
        default:
            message = CommonLocalized.Error.unknown
        }

        return message
    }
}

// MARK: - SbpInteractorOutput

extension SbpPresenter: SbpInteractorOutput {
    func didTokenize(_ data: Tokens) {
        interactor.track(event:
            .actionTokenize(
                scheme: .sbp,
                currentAuthType: interactor.analyticsAuthType()
            )
        )
        moduleOutput?.sbpModule(self, didTokenize: data, paymentMethodType: .sbp)
    }

    func didFailTokenize(_ error: Error) {
        trackScreenPaymentAnalytics(error)

        let errorText = makeErrorText(error)

        DispatchQueue.main.async { [weak self] in
            guard let view = self?.view else { return }
            view.hideActivity()
            view.showPlaceholder(with: errorText, type: .tokenization)
        }
    }

    private func trackScreenPaymentAnalytics(_ error: Error? = nil) {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }

            if error != nil {
                self.interactor.track(
                    event: .screenErrorContract(
                        scheme: .sbp,
                        currentAuthType: self.interactor.analyticsAuthType()
                    )
                )
            } else {
                self.interactor.track(event:
                    .screenPaymentContract(
                        scheme: .sbp,
                        currentAuthType: self.interactor.analyticsAuthType()
                    )
                )
            }
        }
    }
}

// MARK: - SbpModuleInput

extension SbpPresenter: SbpModuleInput {
    func hideActivity() {
        view?.hideActivity()
    }

    func confirmPayment(clientApplicationKey: String, confirmationUrl: String) {
        self.clientApplicationKey = clientApplicationKey
        self.confirmationUrl = confirmationUrl

        DispatchQueue.main.async { [weak self, clientApplicationKey, confirmationUrl] in
            guard let self = self, let view = self.view else { return }
            view.showActivity()
            view.hidePlaceholder()

            dispatchPromise { [weak self] in
                self?.interactor.fetchConfirmationDetails(
                    clientApplicationKey: clientApplicationKey,
                    confirmationUrl: confirmationUrl
                ) ?? .canceling
            }
            .right { [weak self] in
                self?.checkSbpPaymentStatus(
                    clientApplicationKey: clientApplicationKey,
                    paymentId: $0.0,
                    confirmationUrl: $0.1
                )
            }
            .left { [weak self] _ in
                self?.view?.showPlaceholder(
                    with: Localized.CommonPlaceholder.title,
                    type: .confirmation
                )
            }
            .always { [weak self] _ in
                self?.view?.hideActivity()
            }
        }
    }

    private func checkSbpPaymentStatus(
        clientApplicationKey: String,
        paymentId: String,
        confirmationUrl: URL
    ) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self, let view = self.view else { return }
            view.showActivity()
            view.hidePlaceholder()

            dispatchPromise { [weak self] in
                self?.interactor.fetchSbpPayment(
                    clientApplicationKey: clientApplicationKey,
                    paymentId: paymentId
                ) ?? .canceling
            }
            .right { [weak self] payment in
                guard let self = self else { return }

                if case .finished = payment.sbpUserPaymentProcessStatus {
                    self.moduleOutput?.sbpModule(self, didFinishConfirmation: .sbp)
                } else {
                    self.openSbpBanks(
                        clientApplicationKey: clientApplicationKey,
                        paymentId: paymentId,
                        confirmationUrl: confirmationUrl
                    )
                }
            }
            .left { [weak self] _ in
                self?.view?.showPlaceholder(
                    with: Localized.CommonPlaceholder.title,
                    type: .confirmation
                )
            }
            .always { [weak self] _ in
                self?.view?.hideActivity()
            }
        }
    }

    func openSbpBanks(
        clientApplicationKey: String,
        paymentId: String,
        confirmationUrl: URL
    ) {
        let inputData = SbpConfirmationModuleInputData(
            clientApplicationKey: clientApplicationKey,
            confirmationUrl: confirmationUrl.absoluteString,
            paymentId: paymentId,
            testModeSettings: self.testModeSettings,
            isLoggingEnabled: self.isLoggingEnabled
        )
        self.router.openSbpConfirmationModule(inputData: inputData, moduleOutput: self)
    }
}

// MARK: - SbpConfirmationModuleOutput

extension SbpPresenter: SbpConfirmationModuleOutput {
    func sbpConfirmationModule(_ module: SbpConfirmationModuleInput, didFinishWithError: Error) { }

    func sbpConfirmationModule(_ module: SbpConfirmationModuleInput, didFinishWithStatus: SbpPaymentStatus) {
          self.moduleOutput?.sbpModule(self, didFinishConfirmation: .sbp)
    }

    func sbpConfirmationModuleDidClose(_ module: SbpConfirmationModuleInput) {
        // self.moduleOutput?.sbpModule(self, didFinishConfirmation: .sbp)
    }
}

// MARK: - Localized

private extension SbpPresenter {
    enum Localized {
    // swiftlint:disable:next superfluous_disable_command
    // swiftlint:disable line_length
        static let autopaymentsTitle = NSLocalizedString(
            "SbpModule.AutopaymentsTitle",
            bundle: Bundle.framework,
            value: "Заплатив здесь, вы разрешаете <a href='https://yoomoney.ru/page?id=526623'>автосписания</>",
            comment: "Текст на контракте с описанием автосписаний"
        )
        enum CommonPlaceholder {
            static let title = NSLocalizedString(
                "SbpView.CommonPlaceholder.Title",
                bundle: Bundle.framework,
                value: "Не сработало",
                comment: "Title плейсхолдера на экране СБП"
            )
        }
    // swiftlint:enable line_length
    }
}

// MARK: - Constants

private extension SbpPresenter {
    enum Constants { }
}
