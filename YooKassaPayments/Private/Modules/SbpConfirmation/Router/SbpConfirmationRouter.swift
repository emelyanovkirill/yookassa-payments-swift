import YooMoneyUI

final class SbpConfirmationRouter {
	weak var transitionHandler: TransitionHandler?
}

// MARK: - SbpConfirmationRouterInput

extension SbpConfirmationRouter: SbpConfirmationRouterInput {

    func openMoreBanks(
        inputData: SbpBankSelectionInputData,
        moduleOutput: SbpBankSelectionModuleOutput
    ) {
        let module = SbpBankSelectionAssembly.makeModule(
            inputData: inputData,
            moduleOutput: moduleOutput
        )
        transitionHandler?.push(module.view, animated: true)
    }

    func openBankApp(url: URL, completion: ((Bool) -> Void)?) {
        UIApplication.shared.open(url, options: [:], completionHandler: completion)
    }
}
