import FunctionalSwift

final class SbpConfirmationInteractor {

    private let banksService: SbpBanksService
    private let paymentService: PaymentService
    private let clientApplicationKey: String
    private let analyticsService: AnalyticsTracking
    private let imageDownloadService: ImageDownloadService

    // MARK: - Init

	init(
        banksService: SbpBanksService,
        paymentService: PaymentService,
        clientApplicationKey: String,
        analyticsService: AnalyticsTracking,
        imageDownloadService: ImageDownloadService
    ) {
        self.banksService = banksService
        self.paymentService = paymentService
        self.clientApplicationKey = clientApplicationKey
        self.analyticsService = analyticsService
        self.imageDownloadService = imageDownloadService
    }
}

// MARK: - SbpConfirmationInteractorInput

extension SbpConfirmationInteractor: SbpConfirmationInteractorInput {

    func fetchAllBanks(paymentId: String) -> Promise<Error, [SbpBank]> {
        banksService.fetchBanks(
            clientApplicationKey: clientApplicationKey,
            paymentId: paymentId
        )
    }

    func fetchSbpPayment(
        clientApplicationKey: String,
        paymentId: String
    ) -> Promise<Error, SbpPayment> {
        paymentService.fetchPayment(clientApplicationKey: clientApplicationKey, paymentId: paymentId)
    }

    func track(event: AnalyticsEvent) {
        analyticsService.track(event: event)
    }

    func trackAsync(event: AnalyticsEvent) async {
        _ = Task.detached {
            self.analyticsService.track(event: event)
        }
    }

    func fetchImage(url: URL) -> Promise<Error, UIImage> {
        imageDownloadService.fetchImage(url: url)
    }
}
