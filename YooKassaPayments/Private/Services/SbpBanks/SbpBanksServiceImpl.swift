import FunctionalSwift
import YooKassaPaymentsApi
import YooMoneyCoreApi

class SbpBanksServiceImpl {

    private let session: ApiSession

    // MARK: - Init

    init(session: ApiSession) {
        self.session = session
    }
}

extension SbpBanksServiceImpl: SbpBanksService {

    func fetchBanks(clientApplicationKey: String, paymentId: String) -> Promise<Error, [SbpBank]> {
        let apiMethod = YooKassaPaymentsApi.SbpWidgetBanks.Method(
            oauthToken: clientApplicationKey,
            paymentId: paymentId
        )
        return session.perform(apiMethod: apiMethod)
            .responsePromise()
            .map {
                $0.banks.map(SbpBank.init)
            }
    }
}
