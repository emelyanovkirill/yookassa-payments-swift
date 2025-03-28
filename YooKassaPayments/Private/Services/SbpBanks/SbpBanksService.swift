import FunctionalSwift

protocol SbpBanksService {
    func fetchBanks(
        clientApplicationKey: String,
        paymentId: String
    ) -> Promise<Error, [SbpBank]>
}
