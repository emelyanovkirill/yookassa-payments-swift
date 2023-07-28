import UIKit
import YooMoneyUI

typealias SbpBankSelectionModule = (view: UIViewController, moduleInput: SbpBankSelectionModuleInput)

protocol SbpBankSelectionViewOutput: ActionTitleTextDialogDelegate {
    func setupView()
    func didSelectViewModel(at index: Int)
}

protocol SbpBankSelectionViewInput: AnyObject, PlaceholderPresenting, PlaceholderProvider {
    func setViewModels(_ viewModels: [SbpBankSelectionViewModel])
    func showMissedBankPlaceholder()
    func hidePlaceholder()
}
