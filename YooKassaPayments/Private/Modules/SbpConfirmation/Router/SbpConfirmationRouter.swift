import UIKit
internal import YooMoneyUI

final class SbpConfirmationRouter {
	weak var transitionHandler: TransitionHandler?
}

// MARK: - SbpConfirmationRouterInput

extension SbpConfirmationRouter: SbpConfirmationRouterInput {

    func openBankApp(url: URL, completion: ((Bool) -> Void)?) {
        UIApplication.shared.open(url, options: [:], completionHandler: completion)
    }
}
