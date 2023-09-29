import YooKassaPaymentsApi

public enum ConfirmationData {
    case sbp(URL)
    case sberbank(merchantLogin: String, orderId: String)
}

extension ConfirmationData {
    init(_ confirmationData: YooKassaPaymentsApi.ConfirmationData) {
        switch confirmationData {
        case let .sbp(url):
            self = .sbp(url)
        case let .sberbank(merchantLogin: merchantLogin, orderId: orderId):
            self = .sberbank(merchantLogin: merchantLogin, orderId: orderId)
        }
    }
}
