import UIKit

/// SbpConfirmation view input
protocol SbpConfirmationViewInput:
    ActivityIndicatorPresenting, PlaceholderPresenting, NotificationPresenting, PlaceholderProvider {
    func showPlaceholder(message: String)
    func showMissedBankPlaceholder()
    func setViewModels(_ banks: [SbpBankCellViewModel])
    func hidePlaceholder()
    func showSearch()
    func hideSearch()
    func updateImage(_ image: UIImage?, name: String)
}

/// SbpConfirmation view output
protocol SbpConfirmationViewOutput: ActionTitleTextDialogDelegate {
	func setupView()
    func didAppear()
    func didSelectViewModel(_ model: SbpBankCellViewModel)
    func loadLogo(urls: [URL])
}
