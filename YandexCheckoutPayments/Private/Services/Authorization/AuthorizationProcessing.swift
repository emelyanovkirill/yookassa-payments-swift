import class When.Promise
import enum YandexCheckoutWalletApi.AuthType
import struct YandexCheckoutWalletApi.AuthTypeState
import struct YandexCheckoutWalletApi.MonetaryAmount

enum AuthorizationProcessingError: Error {
    case passportNotAuthorized
}

protocol AuthorizationProcessing {
    func getMoneyCenterAuthToken() -> String?

    func setMoneyCenterAuthToken(
        _ token: String
    )

    func getWalletToken() -> String?

    func setWalletToken(
        _ token: String
    )

    func hasReusableWalletToken() -> Bool

    func logout()

    // MARK: - Wallet 2FA

    func loginInYamoney(
        merchantClientAuthorization: String,
        amount: MonetaryAmount,
        reusableToken: Bool
    ) -> Promise<YamoneyLoginResponse>

    func startNewAuthSession(
        merchantClientAuthorization: String,
        contextId: String,
        authType: AuthType
    ) -> Promise<AuthTypeState>

    func checkUserAnswer(
        merchantClientAuthorization: String,
        authContextId: String,
        authType: AuthType,
        answer: String,
        processId: String
    ) -> Promise<YamoneyLoginResponse>
}
