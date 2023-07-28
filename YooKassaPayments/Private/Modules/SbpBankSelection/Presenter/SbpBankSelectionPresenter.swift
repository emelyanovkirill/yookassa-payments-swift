import Foundation

class SbpBankSelectionPresenter {

    // MARK: - VIPER

    weak var view: SbpBankSelectionViewInput?
    weak var moduleOutput: SbpBankSelectionModuleOutput?

    // MARK: - Init data

    let items: [SbpBank]

    init(items: [SbpBank]) {
        self.items = items
    }

    // MARK: - Misc

    private func makeViewModels(_ items: [SbpBank]) -> [SbpBankSelectionViewModel] {
        return items.compactMap {
            .init(title: $0.localizedName)
        }
    }
}

// MARK: - SbpBankSelectionViewOutput

extension SbpBankSelectionPresenter: SbpBankSelectionViewOutput {

    func setupView() {
        let viewModels = makeViewModels(items)
        view?.setViewModels(viewModels)
    }

    func didSelectViewModel(at index: Int) {
        moduleOutput?.sbpBankSelectionModule(self, didSelectItemAt: index)
    }
}

// MARK: - ActionTitleTextDialogDelegate

extension SbpBankSelectionPresenter: ActionTitleTextDialogDelegate {
    func didPressButton(in actionTitleTextDialog: ActionTitleTextDialog) {
        view?.hidePlaceholder()
    }
}

// MARK: - SbpBankSelectionModuleInput

extension SbpBankSelectionPresenter: SbpBankSelectionModuleInput {
    func handleMissedBankError() {
        view?.showMissedBankPlaceholder()
    }
}
