import FunctionalSwift

final class SbpConfirmationPresenter {

    // MARK: - VIPER

    var interactor: SbpConfirmationInteractorInput!
    var router: SbpConfirmationRouterInput!
    weak var moduleOutput: SbpConfirmationModuleOutput?
	weak var view: SbpConfirmationViewInput?

    private let confirmationUrl: String
    private var bankItems: [SbpBank] = []
    private var isWaitingForBankRedirect = false
    private let paymentId: String
    private let clientApplicationKey: String
    private var images: [URL: UIImage] = [:]
    private var loadingImagesUrls: Set<URL> = []

    // MARK: - Init data

    init(
        confirmationUrl: String,
        paymentId: String,
        clientApplicationKey: String
    ) {
        self.confirmationUrl = confirmationUrl
        self.paymentId = paymentId
        self.clientApplicationKey = clientApplicationKey
        YKSdk.shared.sbpConfirmationModuleInput = self
    }
}

// MARK: - SbpConfirmationViewOutput

extension SbpConfirmationPresenter: SbpConfirmationViewOutput {
    func setupView() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )

        fetchData()
    }

    func didAppear() {
        DispatchQueue.global().async { [weak self] in
            self?.interactor.track(
                event: AnalyticsEvent.showBankFullList
            )
        }
    }

    func didSelectViewModel(_ model: SbpBankCellViewModel) {
        trackDidSelectBankAction(model)
        openBankApp(url: model.url) { [weak self] isSuccess in
            if !isSuccess {
                self?.view?.showMissedBankPlaceholder()
            }
        }
    }

    private func trackDidSelectBankAction(_ action: SbpBankCellViewModel) {
        DispatchQueue.global().async { [weak self] in
            let isDeeplink: Bool
            if let scheme = action.url.scheme, !(scheme == "http" || scheme == "https") {
                isDeeplink = true
            } else {
                isDeeplink = false
            }
            self?.interactor.track(
                event: AnalyticsEvent.actionSelectOrdinaryBank(isDeeplink: isDeeplink)
            )
        }
    }

    func loadLogo(urls: [URL]) {
        urls.forEach { loadImageIfNeeded(logoUrl: $0) }
    }

    @objc
    private func applicationDidBecomeActive() {
        fetchPaymentStatus()
    }
}

// MARK: - SbpModuleInput

extension SbpConfirmationPresenter: SbpConfirmationModuleInput {
    func checkSbpPaymentStatus() {
        fetchPaymentStatus()
    }
}

private extension SbpConfirmationPresenter {

    func fetchPaymentStatus() {
        guard isWaitingForBankRedirect else { return }
        isWaitingForBankRedirect = false

        view?.showActivity()
        view?.hidePlaceholder()

        dispatchPromise { [weak self, clientApplicationKey, paymentId] in
            self?.interactor.fetchSbpPayment(
                clientApplicationKey: clientApplicationKey,
                paymentId: paymentId
            ) ?? .canceling
        }
        .right { [weak self] payment in
            guard let self = self else { return }

            if case .finished = payment.sbpUserPaymentProcessStatus {
                self.moduleOutput?.sbpConfirmationModule(self, didFinishWithStatus: payment.sbpPaymentStatus)
                self.interactor.track(
                    event: AnalyticsEvent.actionSBPConfirmation(success: true)
                )
            }
        }
        .left { [weak self] error in
            guard let self = self else { return }

            self.interactor.track(
                event: AnalyticsEvent.actionSBPConfirmation(success: false)
            )
            self.moduleOutput?.sbpConfirmationModule(self, didFinishWithError: error)
            self.handleFailedResponse(error)
        }
        .always { [weak self] _ in
            self?.view?.hideActivity()
        }
    }

    func handleFailedResponse(_ error: Error) {
        let message = makeErrorMessage(error)

        DispatchQueue.main.async { [weak self] in
            guard let view = self?.view else { return }
            view.showPlaceholder(message: message)
        }
    }

    func fetchData() {
        view?.showActivity()
        view?.hidePlaceholder()

        dispatchPromise { [weak self, paymentId] in
            self?.interactor.fetchAllBanks(paymentId: paymentId) ?? .canceling
        }
        .right { [weak self] banks in
            guard let self else { return }

            let defaultImage = UIImage(systemName: "circle.fill") ?? UIImage()
            self.bankItems = banks
            self.setBanks(banks, defaultLogo: defaultImage)
        }
        .left { [weak self] error in
            guard let self = self, let view = self.view else { return }
            view.showPlaceholder(message: self.makeErrorMessage(error))
        }
        .always { [weak self] _ in
            self?.view?.hideActivity()
        }
    }

    private func setBanks(_ banks: [SbpBank], defaultLogo: UIImage) {
        view?.showSearch()
        let viewModels = banks.map {
            SbpBankCellViewModel(
                name: $0.name,
                logo: images[$0.logoUrl] ?? defaultLogo,
                url: $0.url,
                logoUrl: $0.logoUrl,
                logoLoaded: images[$0.logoUrl] != nil
            )
        }
        view?.setViewModels(viewModels)
    }

    private func makeErrorMessage(_ error: Error) -> String {
        var errorMessage: String
        switch error {
        case let error as PresentableError:
            errorMessage = error.message
        default:
            errorMessage = CommonLocalized.Error.unknown
        }
        return errorMessage
    }

    private func openBankApp(url: URL, completion: ((Bool) -> Void)?) {
        guard !isWaitingForBankRedirect else { return }
        isWaitingForBankRedirect = true
        router.openBankApp(url: url) { [weak self] isSuccess in
            self?.isWaitingForBankRedirect = isSuccess
            completion?(isSuccess)
        }
    }

    private func loadImageIfNeeded(logoUrl: URL) {
        guard images[logoUrl] == nil, !loadingImagesUrls.contains(logoUrl) else { return }
        loadingImagesUrls.insert(logoUrl)
        DispatchQueue.global().async { [weak self] in
            self?.interactor.fetchImage(url: logoUrl)
                .map(on: .main, { $0 })
                .right { [weak self] image in
                    guard let self else { return }
                    self.images[logoUrl] = image.scaled(to: Constants.imageSize)
                    if let bank = self.bankItems.first(where: { $0.logoUrl == logoUrl }) {
                        view?.updateImage(self.images[logoUrl], name: bank.name)
                    }
                }
                .always { [weak self] _ in
                    self?.loadingImagesUrls.remove(logoUrl)
                }
        }
    }
}

// MARK: - ActionTitleTextDialogDelegate

extension SbpConfirmationPresenter: ActionTitleTextDialogDelegate {
    func didPressButton(
        in actionTitleTextDialog: ActionTitleTextDialog
    ) {
        fetchData()
    }
}

// MARK: - Localized

private extension SbpConfirmationPresenter {
    enum Localized {
    // swiftlint:disable:next superfluous_disable_command
    // swiftlint:disable line_length
    // swiftlint:enable line_length
    }
}

// MARK: - Constants

private extension SbpConfirmationPresenter {
    enum Constants {
        static let imageSize = CGSize(width: Space.fivefold, height: Space.fivefold)
    }
}
