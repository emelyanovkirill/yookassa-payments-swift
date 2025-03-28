import Foundation
import YooKassaPaymentsApi

struct SbpBank {
    let name: String
    let url: URL
    let logoUrl: URL
}

extension SbpBank {

    init(_ info: YooKassaPaymentsApi.SbpWidgetBankInfo) {
        self.url = info.url
        self.logoUrl = info.logo
        self.name = info.name
    }
}
