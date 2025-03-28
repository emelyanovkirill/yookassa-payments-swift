import YooMoneyPinning

final class PinningApiEnvironmentProvider: YooMoneyPinning.ApiEnvironmentProvider {

    let isDevHost: Bool

    init(isDevHost: Bool) {
        self.isDevHost = isDevHost
    }
}
