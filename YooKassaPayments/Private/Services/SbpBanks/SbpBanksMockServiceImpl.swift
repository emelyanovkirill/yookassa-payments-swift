import FunctionalSwift

class SbpBanksMockServiceImpl: SbpBanksService {
    func fetchBanks(
        clientApplicationKey: String,
        paymentId: String
    ) -> FunctionalSwift.Promise<any Error, [SbpBank]> {
        .right([
            SbpBank(
                name: "СБ",
                // swiftlint:disable:next force_unwrapping
                url: URL(string: "bank100000000111://qr.nspk.ru/BD20003UF46T13KP9S9AQHFR7GC75TMF")!,
                // swiftlint:disable:next force_unwrapping
                logoUrl: URL(string: "https://qr.nspk.ru/proxyapp/logo/bank100000000111.png")!
                // swiftlint:disable:next force_unwrapping
            ),
            SbpBank(
                name: "ТБ",
                // swiftlint:disable:next force_unwrapping
                url: URL(string: "https://www.tinkoff.ru/mybank/payments/qr-pay/BD20003UF46T13KP9S9AQHFR7GC75TMF")!,
                // swiftlint:disable:next force_unwrapping
                logoUrl: URL(string: "https://qr.nspk.ru/proxyapp/logo/bank100000000004.png")!
                // swiftlint:disable:next force_unwrapping
            ),
        ])
    }
}
