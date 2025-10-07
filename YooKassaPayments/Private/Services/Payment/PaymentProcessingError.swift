import YooKassaPaymentsApi

enum PaymentProcessingError: PresentableError {
    case emptyList
    case internetConnection

    var title: String? {
        return nil
    }

    var message: String {
        switch self {
        case .emptyList:
            return localizeString(Localized.Error.emptyPaymentMethodsKey)
        case .internetConnection:
            return localizeString(Localized.Error.internetConnectionKey)
        }
    }

    var style: PresentableNotificationStyle {
        return .alert
    }
    var actions: [PresentableNotificationAction] {
        return []
    }
}

// MARK: - Localized

private extension PaymentProcessingError {
    enum Localized {
        enum Error {
            static let emptyPaymentMethodsKey = "Error.emptyPaymentOptions"
            static let internetConnectionKey = "Error.internet"
            static let emptyPaymentMethods = NSLocalizedString(
                "Error.emptyPaymentOptions",
                bundle: Bundle.framework,
                value: "Нет доступных способов оплаты",
                comment: "Ошибка `Нет доступных способов оплаты` на экране выбора способа оплаты"
            )
            static let internetConnection = NSLocalizedString(
                "Error.internet",
                bundle: Bundle.framework,
                value: "Проблема с интернетом. Попробуйте еще раз, когда будете онлайн",
                comment: "Ошибка `Проблема с интернетом`"
            )
        }
    }
}
