import MoneyAuth

class PaymentMethodsRouter: NSObject {
    
    // MARK: - VIPER
    
    weak var transitionHandler: TransitionHandler?
}

// MARK: - PaymentMethodsRouterInput

extension PaymentMethodsRouter: PaymentMethodsRouterInput {
    func presentYooMoney(
        inputData: YooMoneyModuleInputData,
        moduleOutput: YooMoneyModuleOutput?
    ) {
        let viewController = YooMoneyAssembly.makeModule(
            inputData: inputData,
            moduleOutput: moduleOutput
        )
        transitionHandler?.push(viewController, animated: true)
    }
    
    func closeYooMoneyModule() {
        transitionHandler?.popTopViewController(animated: true)
    }
    
    func presentLinkedCard(
        inputData: LinkedCardModuleInputData,
        moduleOutput: LinkedCardModuleOutput?
    ) {
        let viewController = LinkedCardAssembly.makeModule(
            inputData: inputData,
            moduleOutput: moduleOutput
        )
        transitionHandler?.push(viewController, animated: true)
    }
    
    func closeLinkedCardModule() {
        transitionHandler?.popTopViewController(animated: true)
    }
    
    func presentYooMoneyAuthorizationModule(
        config: MoneyAuth.Config,
        customization: MoneyAuth.Customization,
        output: MoneyAuth.AuthorizationCoordinatorDelegate
    ) throws -> MoneyAuth.AuthorizationCoordinator {

        let coordinator = MoneyAuth.AuthorizationCoordinator(
            processType: .login,
            config: config,
            customization: customization
        )
        coordinator.delegate = output
        let viewController = try coordinator.makeInitialViewController()
        viewController.view.tintColor = CustomizationStorage.shared.mainScheme
        transitionHandler?.present(
            viewController,
            animated: true,
            completion: nil
        )
        return coordinator
    }

    func closeAuthorizationModule() {
        transitionHandler?.dismiss(animated: true, completion: nil)
    }

    func shouldDismissAuthorizationModule() -> Bool {
        return transitionHandler?.presentedViewController != nil
    }
}
