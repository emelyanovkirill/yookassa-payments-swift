/// SbpConfirmation view input
protocol SbpConfirmationViewInput:
    ActivityIndicatorPresenting, PlaceholderPresenting, NotificationPresenting, PlaceholderProvider {
    func showPlaceholder(message: String)
    func showMissedBankPlaceholder()
    func setViewModels(_ banks: [SbpBankCellViewModel])
    func hidePlaceholder()
}

/// SbpConfirmation view output
protocol SbpConfirmationViewOutput: ActionTitleTextDialogDelegate {
	func setupView()
    func didSelectBankItemAction(_ action: SbpBankCellActionType)
}
