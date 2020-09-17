import MoneyAuth

final class YandexAuthRouter {
    weak var transitionHandler: TransitionHandler?
}

// MARK: - YandexAuthRouterInput

extension YandexAuthRouter: YandexAuthRouterInput {
    func presentAuthorizationModule(
        config: MoneyAuth.Config,
        output: MoneyAuth.AuthorizationCoordinatorDelegate
    ) throws -> MoneyAuth.AuthorizationCoordinator {

        let coordinator = MoneyAuth.AuthorizationCoordinator(
            processType: .login,
            config: config
        )
        coordinator.delegate = output
        let viewController = try coordinator.makeInitialViewController()
        transitionHandler?.present(viewController, animated: true, completion: nil)
        return coordinator
    }

    func closeAuthorizationModule() {
        transitionHandler?.dismiss(animated: true, completion: nil)
    }
}
