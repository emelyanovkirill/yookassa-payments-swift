import FunctionalSwift

/// SbpConfirmation interactor input
protocol SbpConfirmationInteractorInput {
    func fetchAllBanks(paymentId: String) -> Promise<Error, [SbpBank]>
    func fetchSbpPayment(
        clientApplicationKey: String,
        paymentId: String
    ) -> Promise<Error, SbpPayment>
    func track(event: AnalyticsEvent)
    func trackAsync(event: AnalyticsEvent) async
    func fetchImage(url: URL) -> Promise<Error, UIImage>
}
