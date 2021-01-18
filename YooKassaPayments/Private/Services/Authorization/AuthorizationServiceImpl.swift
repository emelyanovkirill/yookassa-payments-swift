import class When.Promise
import MoneyAuth
import YooKassaWalletApi

final class AuthorizationServiceImpl {

    // MARK: - Init data

    let tokenStorage: KeyValueStoring
    let walletLoginService: WalletLoginProcessing
    let deviceInfoService: DeviceInfoProvider
    let settingsStorage: KeyValueStoring
    let moneyAuthRevokeTokenService: RevokeTokenService?

    // MARK: - Init

    init(
        tokenStorage: KeyValueStoring,
        walletLoginService: WalletLoginProcessing,
        deviceInfoService: DeviceInfoProvider,
        settingsStorage: KeyValueStoring,
        moneyAuthRevokeTokenService: RevokeTokenService?
    ) {
        self.tokenStorage = tokenStorage
        self.walletLoginService = walletLoginService
        self.deviceInfoService = deviceInfoService
        self.settingsStorage = settingsStorage
        self.moneyAuthRevokeTokenService = moneyAuthRevokeTokenService
    }
}

// MARK: - AuthorizationService

extension AuthorizationServiceImpl: AuthorizationService {
    func getMoneyCenterAuthToken() -> String? {
        return tokenStorage.getString(
            for: KeyValueStoringKeys.moneyCenterAuthToken
        )
    }

    func setMoneyCenterAuthToken(
        _ token: String
    ) {
        tokenStorage.set(
            string: token,
            for: KeyValueStoringKeys.moneyCenterAuthToken
        )
    }

    func getWalletToken() -> String? {
        return tokenStorage.getString(
            for: KeyValueStoringKeys.walletToken
        )
    }

    func hasReusableWalletToken() -> Bool {
        return getWalletToken() != nil
            && tokenStorage.getBool(
                for: KeyValueStoringKeys.isReusableWalletToken
            ) == true
    }

    func logout() {
        if let moneyCenterAuthToken = tokenStorage.getString(
            for: KeyValueStoringKeys.moneyCenterAuthToken
        ) {
            moneyAuthRevokeTokenService?.revoke(
                oauthToken: moneyCenterAuthToken,
                completion: { _ in }
            )
        }
        tokenStorage.set(
            string: nil,
            for: KeyValueStoringKeys.moneyCenterAuthToken
        )
        tokenStorage.set(
            string: nil,
            for: KeyValueStoringKeys.walletToken
        )
    }

    func setWalletDisplayName(
        _ walletDisplayName: String?
    ) {
        tokenStorage.set(
            string: walletDisplayName,
            for: Constants.Keys.walletDisplayName
        )
    }

    func getWalletDisplayName() -> String? {
        tokenStorage.getString(
            for: Constants.Keys.walletDisplayName
        )
    }
}

// MARK: - AuthorizationService Wallet 2FA

extension AuthorizationServiceImpl {
    func loginInWallet(
        merchantClientAuthorization: String,
        amount: MonetaryAmount,
        reusableToken: Bool,
        tmxSessionId: String?,
        completion: @escaping (Result<WalletLoginResponse, Error>) -> Void
    ) {
        if let token = getWalletToken(), hasReusableWalletToken() {
            completion(.success(.authorized(CheckoutTokenIssueExecute(accessToken: token))))
            return
        }

        guard let moneyCenterAuthorization = getMoneyCenterAuthToken() else {
            completion(.failure(AuthorizationProcessingError.passportNotAuthorized))
            return
        }

        tokenStorage.set(
            string: nil,
            for: KeyValueStoringKeys.walletToken
        )
        tokenStorage.set(
            bool: reusableToken,
            for: KeyValueStoringKeys.isReusableWalletToken
        )

        let instanceName = deviceInfoService.getDeviceName()
        let amount = reusableToken ? nil : amount
        let paymentUsageLimit: PaymentUsageLimit = reusableToken ? .multiple : .single

        let promiseTmxSessionId: Promise<String>
        if let tmxSessionId = tmxSessionId {
            promiseTmxSessionId = Promise { return tmxSessionId }
        } else {
            promiseTmxSessionId = ThreatMetrixService.profileApp()
        }

        promiseTmxSessionId.always { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(tmxSessionId):
                self.walletLoginService.requestAuthorization(
                    moneyCenterAuthorization: moneyCenterAuthorization,
                    merchantClientAuthorization: merchantClientAuthorization,
                    instanceName: instanceName,
                    singleAmountMax: amount,
                    paymentUsageLimit: paymentUsageLimit,
                    tmxSessionId: tmxSessionId
                ).always { result in
                    switch result {
                    case let .success(response):
                        self.saveWalletLoginInStorage(response: response)
                        completion(.success(response))
                    case let .failure(error):
                        completion(.failure(error))
                    }
                }

            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    func startNewAuthSession(
        merchantClientAuthorization: String,
        contextId: String,
        authType: AuthType,
        completion: @escaping (Result<AuthTypeState, Error>) -> Void
    ) {
        guard let moneyCenterAuthorization = getMoneyCenterAuthToken() else {
            completion(.failure(AuthorizationProcessingError.passportNotAuthorized))
            return
        }

        walletLoginService.startNewSession(
            moneyCenterAuthorization: moneyCenterAuthorization,
            merchantClientAuthorization: merchantClientAuthorization,
            authContextId: contextId,
            authType: authType
        ).always { result in
            switch result {
            case let .success(state):
                completion(.success(state))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    func checkUserAnswer(
        merchantClientAuthorization: String,
        authContextId: String,
        authType: AuthType,
        answer: String,
        processId: String,
        completion: @escaping (Result<WalletLoginResponse, Error>) -> Void
    ) {
        guard let moneyCenterAuthorization = getMoneyCenterAuthToken() else {
            completion(.failure(AuthorizationProcessingError.passportNotAuthorized))
            return
        }

        walletLoginService.checkUserAnswer(
            moneyCenterAuthorization: moneyCenterAuthorization,
            merchantClientAuthorization: merchantClientAuthorization,
            authContextId: authContextId,
            authType: authType,
            answer: answer,
            processId: processId
        ).always { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(token):
                let response = makeWalletLoginResponse(token: token)
                self.saveWalletLoginInStorage(response: response)
                completion(.success(response))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}

// MARK: - Private helpers

private extension AuthorizationServiceImpl {
    func saveWalletLoginInStorage(
        response: WalletLoginResponse
    ) {
        if case let .authorized(data) = response {
            tokenStorage.set(
                string: data.accessToken,
                for: KeyValueStoringKeys.walletToken
            )
        }
    }
}

// MARK: - Constants

private extension AuthorizationServiceImpl {
    enum Constants {
        enum Keys {
            static let walletDisplayName = "walletDisplayName"
        }
    }
}

// MARK: - Private global helpers

private func makeWalletLoginResponse(token: String) -> WalletLoginResponse {
    return .authorized(.init(accessToken: token))
}
