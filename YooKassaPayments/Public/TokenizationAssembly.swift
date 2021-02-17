import UIKit.UIViewController

/// Tokenization module builder.
public enum TokenizationAssembly {

    /// Creates tokenization view controller.
    ///
    /// - Returns: Tokenization view controller which implements the protocol `TokenizationModuleInput`.
    public static func makeModule(
        inputData: TokenizationFlow,
        moduleOutput: TokenizationModuleOutput
    ) -> UIViewController & TokenizationModuleInput {

        switch inputData {
        case .tokenization(let tokenizationModuleInputData):
            CustomizationStorage.shared.mainScheme
                = tokenizationModuleInputData.customizationSettings.mainScheme
            return makeTokenizationModule(tokenizationModuleInputData, moduleOutput: moduleOutput)

        case .bankCardRepeat(let bankCardRepeatModuleInputData):
            CustomizationStorage.shared.mainScheme
                = bankCardRepeatModuleInputData.customizationSettings.mainScheme
            return makeBankCardRepeatModule(bankCardRepeatModuleInputData, moduleOutput: moduleOutput)
        }
    }

    private static func makeBankCardRepeatModule(
        _ inputData: BankCardRepeatModuleInputData,
        moduleOutput: TokenizationModuleOutput
    ) -> UIViewController & TokenizationModuleInput {
        let (viewController, moduleInput) = BankCardRepeatAssembly.makeModule(
            inputData: inputData,
            moduleOutput: moduleOutput
        )

        let navigationController = UINavigationController(
            rootViewController: viewController
        )

        let sheetViewController = SheetViewController(
            contentViewController: navigationController
        )
        sheetViewController.moduleOutput = moduleOutput

        return sheetViewController
    }

    private static func makeTokenizationModule(
        _ inputData: TokenizationModuleInputData,
        moduleOutput: TokenizationModuleOutput
    ) -> UIViewController & TokenizationModuleInput {
        let paymentService = PaymentServiceAssembly.makeService(
            tokenizationSettings: inputData.tokenizationSettings,
            testModeSettings: inputData.testModeSettings,
            isLoggingEnabled: inputData.isLoggingEnabled
        )
        let authorizationService = AuthorizationServiceAssembly.makeService(
            isLoggingEnabled: inputData.isLoggingEnabled,
            testModeSettings: inputData.testModeSettings,
            moneyAuthClientId: inputData.moneyAuthClientId
        )
        let analyticsService = AnalyticsServiceAssembly.makeService(
            isLoggingEnabled: inputData.isLoggingEnabled
        )
        let analyticsProvider = AnalyticsProviderAssembly.makeProvider(
            testModeSettings: inputData.testModeSettings
        )

        let paymentMethodsModuleInputData = PaymentMethodsModuleInputData(
            clientApplicationKey: inputData.clientApplicationKey,
            applePayMerchantIdentifier: inputData.applePayMerchantIdentifier,
            gatewayId: inputData.gatewayId,
            shopName: inputData.shopName,
            purchaseDescription: inputData.purchaseDescription,
            amount: inputData.amount,
            tokenizationSettings: inputData.tokenizationSettings,
            testModeSettings: inputData.testModeSettings,
            isLoggingEnabled: inputData.isLoggingEnabled,
            getSavePaymentMethod: makeGetSavePaymentMethod(inputData.savePaymentMethod),
            moneyAuthClientId: inputData.moneyAuthClientId,
            returnUrl: inputData.returnUrl,
            savePaymentMethod: inputData.savePaymentMethod,
            userPhoneNumber: inputData.userPhoneNumber
        )

        let paymentMethodViewModelFactory = PaymentMethodViewModelFactoryAssembly.makeFactory()
        let presenter = TokenizationPresenter(
            inputData: inputData,
            paymentMethodViewModelFactory: paymentMethodViewModelFactory
        )
        let router = TokenizationRouter()
        let interactor = TokenizationInteractor(
            paymentService: paymentService,
            authorizationService: authorizationService,
            analyticsService: analyticsService,
            analyticsProvider: analyticsProvider,
            clientApplicationKey: inputData.clientApplicationKey
        )

        let (viewController, _) = PaymentMethodsAssembly.makeModule(
            inputData: paymentMethodsModuleInputData,
            moduleOutput: presenter
        )

        presenter.router = router
        presenter.interactor = interactor
        presenter.moduleOutput = moduleOutput

        interactor.output = presenter

        router.transitionHandler = viewController

        let navigationController = UINavigationController(
            rootViewController: viewController
        )

        let sheetViewController = SheetViewController(
            contentViewController: navigationController
        )
        sheetViewController.moduleOutput = moduleOutput

        return sheetViewController
    }
}

extension SheetViewController: TokenizationModuleInput {
    public func start3dsProcess(requestUrl: String) {
        // TODO: Fix in https://jira.yamoney.ru/browse/MOC-1611
    }
}

private func makeGetSavePaymentMethod(
    _ savePaymentMethod: SavePaymentMethod
) -> Bool? {
    let getSavePaymentMethod: Bool?

    switch savePaymentMethod {
    case .on:
        getSavePaymentMethod = true

    case .off:
        getSavePaymentMethod = false

    case .userSelects:
        getSavePaymentMethod = nil
    }

    return getSavePaymentMethod
}
