import MessageUI
import SafariServices
import UIKit
import WebKit
import AppMetricaCore
import YooKassaPayments
import YooMoneyUI
import YooMoneyVision

final class RootViewController: UIViewController {
    public static func makeModule() -> UIViewController {
        return RootViewController(nibName: nil, bundle: nil)
    }

    weak var tokenizationModuleInput: TokenizationModuleInput?

    // MARK: - CardScanningDelegate

    weak var cardScanningDelegate: CardScanningDelegate?

    // MARK: - UI properties

    private lazy var payButton: UIButton = {
        $0.setStyles(UIButton.DynamicStyle.primary)
        $0.setStyledTitle(translate(Localized.buy), for: .normal)
        $0.addTarget(self, action: #selector(payButtonDidPress), for: .touchUpInside)
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UIButton(type: .custom))

    private lazy var favoriteButton: UIButton = {
        $0.setImage(#imageLiteral(resourceName: "Root.Favorite"), for: .normal)
        $0.setContentHuggingPriority(.required, for: .horizontal)
        $0.setContentCompressionResistancePriority(.required, for: .horizontal)
        return $0
    }(UIButton(type: .custom))

    private lazy var priceInputViewController: PriceInputViewController = {
        $0.initialPrice = settings.price
        $0.delegate = self
        return $0
    }(PriceInputViewController())

    private lazy var priceTitleLabel: UILabel = {
        $0.setStyles(UILabel.DynamicStyle.body)
        $0.styledText = translate(Localized.price)
        return $0
    }(UILabel())

    private lazy var ratingLabel: UILabel = {
        $0.setStyles(UILabel.DynamicStyle.body)
        $0.styledText = "5"
        return $0
    }(UILabel())

    private lazy var descriptionLabel: UILabel = {
        $0.setStyles(UILabel.DynamicStyle.body,
                     UILabel.Styles.multiline)
        $0.styledText = translate(Localized.description)
        return $0
    }(UILabel())

    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.setStyles(UILabel.DynamicStyle.title1)
        label.appendStyle(UILabel.Styles.multiline)
        label.styledText = translate(Localized.name)
        return label
    }()

    private lazy var scrollView: UIScrollView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.showsVerticalScrollIndicator = false
        $0.setStyles(UIScrollView.Styles.interactiveKeyboardDismissMode)
        return $0
    }(UIScrollView())

    private lazy var contentView: UIView = {
        $0.setStyles(UIView.Styles.defaultBackground)
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UIView())

    private lazy var imageView = UIImageView(image: #imageLiteral(resourceName: "Root.Comet"))

    private lazy var settingsBarItem = UIBarButtonItem(
        image: #imageLiteral(resourceName: "Root.Settings"),
        style: .plain,
        target: self,
        action: #selector(settingsButtonDidPress)
    )

    private lazy var ratingImageView = UIImageView(image: #imageLiteral(resourceName: "Root.Rating"))

    private lazy var payButtonBottomConstraint: NSLayoutConstraint =
    self.view.layoutMarginsGuide.bottomAnchor.constraint(equalTo: payButton.bottomAnchor)

    private lazy var nameLabelTopConstraint: NSLayoutConstraint =
        nameLabel.top.constraint(equalTo: imageView.bottom)

    private var variableConstraints: [NSLayoutConstraint] = []

    // MARK: - Private properties

    private let settingsService: SettingsService

    private var currentKeyboardOffset: CGFloat = 0

    // MARK: - Data properties

    var token: Tokens?
    var paymentMethodType: PaymentMethodType?
    lazy var settings: Settings = {
        if let settings = settingsService.loadSettingsFromStorage() {
            return settings
        } else {
            let settings = Settings()
            settingsService.saveSettingsToStorage(settings: settings)

            return settings
        }
    }()

    // MARK: - Initialization/Deinitialization

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        let keyValueStorage = UserDefaultsStorage(userDefault: UserDefaults.standard)
        settingsService = SettingsService(storage: keyValueStorage)

        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        addChild(priceInputViewController)
    }

    required init?(coder aDecoder: NSCoder) {
        let keyValueStorage = UserDefaultsStorage(userDefault: UserDefaults.standard)
        settingsService = SettingsService(storage: keyValueStorage)

        super.init(coder: aDecoder)

        addChild(priceInputViewController)
    }

    deinit {
        unsubscribeFromNotifications()
    }

    // MARK: - Managing the View

    override func loadView() {
        view = UIView()
        view.setStyles(UIView.Styles.defaultBackground)

        loadSubviews()
        loadConstraints()

        priceInputViewController.didMove(toParent: self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true

        subscribeOnNotifications()
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startKeyboardObserving()
    }

    override public func viewWillDisappear(_ animated: Bool) {
        stopKeyboardObserving()
        super.viewWillDisappear(animated)
    }

    private func loadSubviews() {
        view.addSubview(scrollView)
        view.addSubview(payButton)
        navigationItem.rightBarButtonItem = settingsBarItem
        scrollView.addSubview(contentView)

        let views: [UIView] = [
            priceTitleLabel,
            priceInputViewController.view,
            ratingImageView,
            ratingLabel,
            descriptionLabel,
            nameLabel,
            favoriteButton,
            imageView,
        ]

        views.forEach { subview in
            subview.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(subview)
        }

        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(rootViewPressed)
        )
        view.addGestureRecognizer(tap)
    }

    private func loadConstraints() {

        let constraints: [NSLayoutConstraint] = [
            scrollView.leading.constraint(equalTo: view.leading),
            scrollView.top.constraint(equalTo: view.top),
            scrollView.trailing.constraint(equalTo: view.trailing),
            payButton.top.constraint(equalTo: scrollView.bottom, constant: Space.quadruple),

            scrollView.leading.constraint(equalTo: contentView.leading),
            scrollView.top.constraint(equalTo: contentView.top),
            scrollView.trailing.constraint(equalTo: contentView.trailing),
            scrollView.bottom.constraint(equalTo: contentView.bottom),
            contentView.width.constraint(equalTo: view.width),

            payButton.leading.constraint(equalTo: contentView.leadingMargin),
            payButton.trailing.constraint(equalTo: contentView.trailingMargin),
            payButtonBottomConstraint,

            priceTitleLabel.leading.constraint(equalTo: contentView.leadingMargin),
            contentView.trailingMargin.constraint(equalTo: priceInputViewController.view.trailing),
            contentView.bottom.constraint(equalTo: priceInputViewController.view.bottom),

            ratingImageView.leading.constraint(equalTo: contentView.leadingMargin),
            ratingLabel.leading.constraint(equalTo: ratingImageView.trailing, constant: Space.single),
            ratingLabel.centerY.constraint(equalTo: ratingImageView.centerY),

            descriptionLabel.leading.constraint(equalTo: contentView.leadingMargin),
            contentView.trailingMargin.constraint(equalTo: descriptionLabel.trailing),
            ratingImageView.top.constraint(equalTo: descriptionLabel.bottom, constant: Space.double),
            descriptionLabel.trailing.constraint(equalTo: contentView.trailingMargin),

            nameLabel.leading.constraint(equalTo: contentView.leadingMargin),
            descriptionLabel.top.constraint(equalTo: nameLabel.bottom, constant: Space.single),

            favoriteButton.leading.constraint(equalTo: nameLabel.trailing, constant: Space.double),
            contentView.trailingMargin.constraint(equalTo: favoriteButton.trailing),
            favoriteButton.centerY.constraint(equalTo: nameLabel.centerY),

            imageView.leading.constraint(equalTo: contentView.leadingMargin),
            contentView.trailingMargin.constraint(equalTo: imageView.trailing),
            imageView.top.constraint(equalTo: contentView.topMargin),
            imageView.height.constraint(equalTo: imageView.width, multiplier: 1),
            nameLabelTopConstraint,
        ]

        NSLayoutConstraint.activate(constraints)

        updateVariableConstraints()
    }

    @objc
    private func accessibilityReapply() {
        payButton.setStyledTitle(translate(Localized.buy), for: .normal)
        ratingLabel.styledText = "5"
        descriptionLabel.styledText = translate(Localized.description)
        nameLabel.styledText = translate(Localized.name)
        priceTitleLabel.styledText = priceTitleLabel.styledText

        updateVariableConstraints()
    }

    private func updatePayButtonBottomConstraint() {
        UIView.animate(withDuration: CATransaction.animationDuration()) {
            if self.traitCollection.horizontalSizeClass == .regular {
                self.payButtonBottomConstraint.constant = Space.fivefold + self.currentKeyboardOffset
            } else {
                self.payButtonBottomConstraint.constant = Space.double + self.currentKeyboardOffset
            }
            self.view.layoutIfNeeded()
        }
    }

    private func updateVariableConstraints() {
        NSLayoutConstraint.deactivate(variableConstraints)

        if UIApplication.shared.preferredContentSizeCategory.isAccessibilitySizeCategory {
            variableConstraints = [
                priceTitleLabel.trailing.constraint(equalTo: contentView.trailing),
                priceInputViewController.view.leading.constraint(equalTo: contentView.leadingMargin),
                priceTitleLabel.bottom.constraint(equalTo: priceInputViewController.view.top, constant: 0),
                priceTitleLabel.top.constraint(equalTo: ratingImageView.bottom, constant: Space.double),
            ]
        } else {
            variableConstraints = [
                priceTitleLabel.trailing.constraint(equalTo: priceInputViewController.view.leading),
                priceInputViewController.view.width
                    .constraint(greaterThanOrEqualToConstant: Constants.priceInputMinWidth),
                priceTitleLabel.top.constraint(equalTo: priceInputViewController.view.top,
                                               constant: Constants.priceTitleLabelTopOffset),
                priceInputViewController.view.top.constraint(equalTo: ratingImageView.bottom),
            ]
        }

        NSLayoutConstraint.activate(variableConstraints)
    }

    // MARK: - Actions

    @objc
    private func payButtonDidPress() {

        guard let price = priceInputViewController.price else {
            return
        }

        token = nil
        paymentMethodType = nil

        priceInputViewController.view.endEditing(true)

        settings.price = price
        settingsService.saveSettingsToStorage(settings: settings)

        let testSettings: TestModeSettings?
        let amount = Amount(value: settings.price, currency: .rub)

        if settings.testModeSettings.isTestModeEnadled {
            let paymentAuthorizationPassed = settings.testModeSettings.isPaymentAuthorizationPassed
            testSettings = TestModeSettings(
                paymentAuthorizationPassed: paymentAuthorizationPassed,
                cardsCount: settings.testModeSettings.cardsCount ?? 0,
                charge: amount,
                enablePaymentError: settings.testModeSettings.isPaymentWithError
            )
        } else {
            testSettings = nil
        }

        let devHostService = DevHostService(storage: UserDefaultsStorage(userDefault: .standard))

        let oauthToken: String

        if devHostService[DevHostService.Keys.devHosKey] {
            oauthToken = devHostService[DevHostService.Keys.merchantKey]
        } else {
            oauthToken = "live_MTkzODU2VY5GiyQq2GMPsCQ0PW7f_RSLtJYOT-mp_CA"
        }

        let data = TokenizationModuleInputData(
           clientApplicationKey: oauthToken,
           shopName: translate(Localized.name),
           shopId: "193856",
           purchaseDescription: translate(Localized.description),
           amount: amount,
           gatewayId: "524505",
           tokenizationSettings: makeTokenizationSettings(),
           testModeSettings: testSettings,
           cardScanning: settings.isBankCardScanEnabled ? self : nil,
           isLoggingEnabled: true,
           userPhoneNumber: "71234567890", // в формате 7XXXXXXXXXX
           customizationSettings: CustomizationSettings(
                mainScheme: .blueRibbon,
                showYooKassaLogo: settings.isShowingYooMoneyLogoEnabled
           ),
           savePaymentMethod: .userSelects,
           moneyAuthClientId: "hitm6hg51j1d3g1u3ln040bajiol903b",
           applicationScheme: "yookassapaymentsexample://",
           customerId: "app.example.demo.payments.yookassa"
        )

        let inputData = TokenizationFlow.tokenization(data)

        // Раскомментируйте код ниже, чтобы запустить сценарий токенизация с сохраненной картой
        // документация метода: https://git.yoomoney.ru/projects/SDK/repos/yookassa-payments-swift/browse#платёж-привязанной-к-магазину-картой-с-дозапросом-cvccvv
//        let inputData: TokenizationFlow = .bankCardRepeat(BankCardRepeatModuleInputData(
//            clientApplicationKey: oauthToken,
//            shopName: translate(Localized.name),
//            purchaseDescription: translate(Localized.description),
//            paymentMethodId: "pi-2cc855c9-0029-5000-8000-099acd97cfa5",
//            amount: amount,
//            testModeSettings: testSettings,
//            isLoggingEnabled: true,
//            customizationSettings: CustomizationSettings(
//                mainScheme: .blueRibbon,
//                showYooKassaLogo: settings.isShowingYooMoneyLogoEnabled
//            ),
//            savePaymentMethod: .userSelects,
//            gatewayId: nil
//        ))

        let viewController = TokenizationAssembly.makeModule(
            inputData: inputData,
            moduleOutput: self
        )
        tokenizationModuleInput = viewController
        present(viewController, animated: true, completion: nil)
    }

    @objc
    private func settingsButtonDidPress() {
        priceInputViewController.view.endEditing(true)

        let module = SettingsViewController.makeModule(settings: settings, delegate: self)
        let navigation = UINavigationController(rootViewController: module)
        navigation.navigationBar.prefersLargeTitles = true
        navigation.modalPresentationStyle = .formSheet

        present(navigation, animated: true, completion: nil)
    }

    @objc
    private func rootViewPressed() {
        view.endEditing(true)
    }

    // MARK: - Notifications

    private func subscribeOnNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(accessibilityReapply),
            name: UIContentSizeCategory.didChangeNotification,
            object: nil
        )
    }

    private func unsubscribeFromNotifications() {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Responding to a Change in the Interface Environment

    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if traitCollection.horizontalSizeClass == .regular {
            payButtonBottomConstraint.constant = Space.fivefold
            nameLabelTopConstraint.constant = Constants.nameTopOffset * 2
            contentView.layoutMargins = UIEdgeInsets(
                top: Space.quadruple,
                left: view.frame.width * Constants.widthRatio,
                bottom: 0,
                right: view.frame.width * Constants.widthRatio
            )
        } else {
            payButtonBottomConstraint.constant = Space.double
            nameLabelTopConstraint.constant = Constants.nameTopOffset
            contentView.layoutMargins = UIEdgeInsets(
                top: Space.single,
                left: Space.double,
                bottom: 0,
                right: Space.double
            )
        }

        updatePayButtonBottomConstraint()
    }

    // MARK: - Data making

    private func makeTokenizationSettings() -> TokenizationSettings {
        var paymentTypes: PaymentMethodTypes = []

        if settings.isBankCardEnabled {
            paymentTypes.insert(.bankCard)
        }
        if settings.isYooMoneyEnabled {
            paymentTypes.insert(.yooMoney)
        }
        if settings.isSberbankEnabled {
            paymentTypes.insert(.sberbank)
        }
        if settings.isSbp {
            paymentTypes.insert(.sbp)
        }

        return TokenizationSettings(
            paymentMethodTypes: paymentTypes
        )
    }
}

// MARK: - SettingsViewControllerDelegate

extension RootViewController: SettingsViewControllerDelegate {
    func settingsViewController(
        _ settingsViewController: SettingsViewController,
        didChangeSettings settings: Settings
    ) {
        self.settings = settings
        settingsService.saveSettingsToStorage(settings: settings)
    }
}

// MARK: - Keyboard Observing

extension RootViewController {

    func startKeyboardObserving() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    func stopKeyboardObserving() {
        NotificationCenter.default.removeObserver(self)
    }

    @objc
    private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardEndFrame = makeKeyboardEndFrame(from: notification) else { return }
        currentKeyboardOffset = keyboardYOffset(from: keyboardEndFrame) ?? 0
        updatePayButtonBottomConstraint()
    }

    @objc
    private func keyboardWillHide(_ notification: Notification) {
        guard let keyboardEndFrame = makeKeyboardEndFrame(from: notification) else { return }
        currentKeyboardOffset = keyboardYOffset(from: keyboardEndFrame) ?? 0
        updatePayButtonBottomConstraint()
    }

    private func makeKeyboardEndFrame(from notification: Notification) -> CGRect? {
        let userInfo = notification.userInfo
        let endFrameValue = userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
        let endFrame = endFrameValue.map { $0.cgRectValue }
        return endFrame
    }

    private func keyboardYOffset(from keyboardFrame: CGRect) -> CGFloat? {
        let convertedKeyboardFrame = view.convert(keyboardFrame, from: nil)
        let intersectionViewFrame = convertedKeyboardFrame.intersection(view.bounds)

        let intersectionSafeFrame = convertedKeyboardFrame.intersection(view.safeAreaLayoutGuide.layoutFrame)
        let safeOffset: CGFloat = intersectionViewFrame.height - intersectionSafeFrame.height

        let intersectionOffset = intersectionViewFrame.size.height
        guard convertedKeyboardFrame.minY.isInfinite == false else {
            return nil
        }
        let keyboardOffset = intersectionOffset + safeOffset
        return keyboardOffset
    }
}

extension RootViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(
        _ controller: MFMailComposeViewController,
        didFinishWith result: MFMailComposeResult,
        error: Error?
    ) {
        controller.dismiss(animated: true)
    }
}

extension RootViewController: PriceInputViewControllerDelegate {
    func priceInputViewController(
        _ priceInputViewController: PriceInputViewController,
        didChangePrice price: Decimal?,
        valid: Bool
    ) {
        if price != nil, valid == true {
            payButton.isEnabled = true
        } else {
            payButton.isEnabled = false
        }

        scrollView.scrollRectToVisible(
            priceInputViewController.view.frame,
            animated: true
        )
    }
}

// MARK: - SuccessViewControllerDelegate

extension RootViewController: SuccessViewControllerDelegate {

    func didPressConfirmButton(on successViewController: SuccessViewController) {
        if settings.testModeSettings.isTestModeEnadled,
           let processConfirmation = settings.testModeSettings.processConfirmation {
            didPressConfirmButton(
                on: successViewController,
                process: processConfirmation
            )
        }
    }

    func didPressConfirmButton(
        on successViewController: SuccessViewController,
        process: ProcessConfirmation
    ) {
        guard let paymentMethodType = self.paymentMethodType else { return }
        successViewController.dismiss(animated: true)

        switch process {
        case let .threeDSecure(requestUrl):
            tokenizationModuleInput?.startConfirmationProcess(
                confirmationUrl: requestUrl,
                paymentMethodType: paymentMethodType
            )

        case let .app2app(confirmationUrl):
            tokenizationModuleInput?.startConfirmationProcess(
                confirmationUrl: confirmationUrl,
                paymentMethodType: paymentMethodType
            )
        case let .sbp(returnUrl):
            tokenizationModuleInput?.startConfirmationProcess(
                confirmationUrl: returnUrl,
                paymentMethodType: .sbp
            )
        }
    }

    func didPressDocumentationButton(on successViewController: SuccessViewController) {
        dismiss(animated: true) { [weak self] in
            let documentationPath: String
            if Locale.current.languageCode == Constants.russianLanguageCode {
                documentationPath = Constants.documentationPathRu
            } else {
                documentationPath = Constants.documentationPathEn
            }

            guard let self = self,
                  let url = URL(string: documentationPath) else {
                return
            }

            let viewController = SFSafariViewController(url: url)
            viewController.dismissButtonStyle = .close

            self.present(viewController, animated: true)
        }
    }

    func didPressSendTokenButton(on successViewController: SuccessViewController) {
        guard let token = token, let paymentMethodType = paymentMethodType else {
            assertionFailure("Missing token or paymentMethodType")
            return
        }
        let message = """
                Token: \(token.paymentToken)
                Payment method: \(paymentMethodType.rawValue)
            """

        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }

            let viewController: UIViewController

            if MFMailComposeViewController.canSendMail() == false {
                let alertController = UIAlertController(
                    title: "Token",
                    message: message,
                    preferredStyle: .alert
                )
                let action = UIAlertAction(title: "OK", style: .default)
                alertController.addAction(action)
                viewController = alertController
            } else {
                let mailController = MFMailComposeViewController()

                mailController.mailComposeDelegate = self
                mailController.setSubject("iOS App: Payment Token")
                mailController.setMessageBody(message, isHTML: false)

                viewController = mailController
            }

            self.present(viewController, animated: true)
        }
    }

    func didPressClose(on successViewController: SuccessViewController) {
        dismiss(animated: true)
    }
}

private extension RootViewController {
    enum Localized: String {
        case price = "root.price"
        case buy = "root.buy"
        case description = "root.description"
        case name = "root.name"
    }
}

private extension RootViewController {
    enum Constants {
        static let widthRatio: CGFloat = 0.125
        static let nameTopOffset: CGFloat = 25
        static let heightRatio: CGFloat = 0.15
        static let priceTitleLabelTopOffset: CGFloat = 37.0
        static let priceInputMinWidth: CGFloat = 156.0

        static let russianLanguageCode = "ru"
        static let documentationPathRu = "https://yookassa.ru/developers/using-api/using-sdks"
        static let documentationPathEn = "https://yookassa.ru/en/developers/using-api/using-sdks"
    }
}

// MARK: - BankCardScannerModuleOutput

extension RootViewController: BankCardScannerModuleOutput {

    func bankCardScannerModuleDidRecognize(
        _ module: BankCardScannerModuleInput,
        number: String?,
        expirationDate: (month: String, year: String)?,
        securityCode: String?
    ) {
        DispatchQueue.main.async { [weak self] in
            let scannedCardInfo = ScannedCardInfo(
                number: number,
                expiryMonth: "\(expirationDate?.month ?? "")",
                expiryYear: "\(expirationDate?.year ?? "")"
            )
            self?.cardScanningDelegate?.cardScannerDidFinish(scannedCardInfo)
        }
    }
}

extension RootViewController: CardScanning {
    var cardScanningViewController: UIViewController? {
        let inputData = BankCardScannerModuleInputData(
            numberRecognitionPriority: .required,
            expirationDateRecognitionPriority: .required,
            securityCodeRecognitionPriority: .needless
        )
        return BankCardScannerAssembly.makeModule(
            inputData: inputData,
            moduleOutput: self
        ).viewController
    }
}
