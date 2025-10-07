import UIKit.UIAlertController

enum LogoutConfirmationAssembly {
    static func makeModule(
        inputData: LogoutConfirmationModuleInputData,
        moduleOutput: LogoutConfirmationModuleOutput
    ) -> UIViewController {
        let viewController = UIAlertController(
            title: String.localizedStringWithFormat(
                localizeString(Localized.titleFormatKey),
                inputData.accountName
            ),
            message: nil,
            preferredStyle: .alert
        )

        [
            UIAlertAction(
                title: localizeString(CommonLocalized.Alert.cancelKey),
                style: .default,
                handler: { [weak moduleOutput] _ in
                    moduleOutput?.logoutDidCancel(on: viewController)
                }
            ),
            UIAlertAction(
                title: localizeString(CommonLocalized.Alert.okKey),
                style: .destructive,
                handler: { [weak moduleOutput] _ in
                    moduleOutput?.logoutDidConfirm(on: viewController)
                }
            ),
        ].forEach(viewController.addAction)

        return viewController
    }
}

// MARK: - Localized

private enum Localized {
    static let titleFormatKey = "LogoutConfirmation.format.title"
    static let titleFormat = NSLocalizedString(
        "LogoutConfirmation.format.title",
        bundle: Bundle.framework,
        value: "Уверены, что хотите выйти из аккаунта '%@'?",
        comment: "Текст в Alert при выходе из аккаунта ЮMoney https://yadi.sk/i/68ImXb9rz31RkQ"
    )
}
