import Foundation

/// SbpConfirmation router input
protocol SbpConfirmationRouterInput: AnyObject {
    func openBankApp(url: URL, completion: ((Bool) -> Void)?)
}
