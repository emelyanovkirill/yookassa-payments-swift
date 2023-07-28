/// Sbp router input
protocol SbpRouterInput: AnyObject {
    func showBrowser(url: URL)
    func showSafeDealInfo(title: String, body: String)
    func openSbpConfirmationModule(
        inputData: SbpConfirmationModuleInputData,
        moduleOutput: SbpConfirmationModuleOutput
    )
}
