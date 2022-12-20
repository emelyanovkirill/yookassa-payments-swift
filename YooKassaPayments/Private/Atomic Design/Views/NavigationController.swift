import UIKit

final class NavigationController: UINavigationController {
    weak var moduleOutput: SheetViewModuleOutput?

    override func viewDidLoad() {
        presentationController?.delegate = self
    }
}

// MARK: - UIAdaptivePresentationControllerDelegate

extension NavigationController: UIAdaptivePresentationControllerDelegate {
    public func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        guard UIScreen.main.traitCollection.userInterfaceIdiom == .pad else { return }

        moduleOutput?.didFinish(on: self, with: nil)
    }
}

// MARK: - TokenizationModuleInput

extension NavigationController: TokenizationModuleInput {
    func start3dsProcess(requestUrl: String) {
        moduleOutput?.start3dsProcess(requestUrl: requestUrl)
    }

    func startConfirmationProcess(
        confirmationUrl: String,
        paymentMethodType: PaymentMethodType
    ) {
        moduleOutput?.startConfirmationProcess(
            confirmationUrl: confirmationUrl,
            paymentMethodType: paymentMethodType
        )
    }
}
