import UIKit.UIImage

final class ErrorPresenter {

    // MARK: - VIPER

    weak var view: ErrorViewInput?
    weak var moduleOutput: ErrorModuleOutput?

    // MARK: - Init data

    fileprivate let inputData: ErrorModuleInputData

    // MARK: - Init

    init(inputData: ErrorModuleInputData) {
        self.inputData = inputData
    }
}

// MARK: - ErrorViewOutput

extension ErrorPresenter: ErrorViewOutput {
    func setupView() {
        guard let view = view else { return }
        view.showPlaceholder(message: inputData.errorTitle)
    }
}

// MARK: - ActionTextDialogDelegate

extension ErrorPresenter: ActionTextDialogDelegate {
    func didPressButton() {
        moduleOutput?.didPressPlaceholderButton(on: self)
    }
}

// MARK: - ErrorModuleInput

extension ErrorPresenter: ErrorModuleInput {}
