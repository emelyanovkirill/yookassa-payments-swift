import YooMoneyCoreApi
import YooMoneyPinning

final class ApiLogger { }

// MARK: - Logger

extension ApiLogger: YooMoneyCoreApi.Logger {
    func log(message: String) {
        #if DEBUG
        print(message)
        #endif
    }
}

// MARK: - YooMoneyPinning.Logger

extension ApiLogger: YooMoneyPinning.Logger { }
