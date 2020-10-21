import YandexCheckoutPayments
import YandexCheckoutPaymentsApi

// MARK: - TokenizationModuleOutput

extension RootViewController: TokenizationModuleOutput {
    func tokenizationModule(_ module: TokenizationModuleInput,
                            didTokenize token: Tokens,
                            paymentMethodType: PaymentMethodType) {

        self.token = token
        self.paymentMethodType = paymentMethodType

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            let successViewController = SuccessViewController()
            successViewController.delegate = self

            if let presentedViewController = self.presentedViewController {
                presentedViewController.show(successViewController, sender: self)
            } else {
                self.present(successViewController, animated: true)
            }
        }
    }

    func didFinish(on module: TokenizationModuleInput,
                   with error: YandexCheckoutPaymentsError?) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.dismiss(animated: true)
        }
    }

    func didSuccessfullyPassedCardSec(on module: TokenizationModuleInput) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let alertController = UIAlertController(title: "3D-Sec",
                                                    message: "Successfully passed 3d-sec",
                                                    preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default)
            alertController.addAction(action)
            self.dismiss(animated: true)
            self.present(alertController, animated: true)
        }
    }
}
