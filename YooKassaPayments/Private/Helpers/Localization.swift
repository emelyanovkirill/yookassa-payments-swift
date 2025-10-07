import Foundation

// MARK: - Localization
enum CommonLocalized {
    // swiftlint:disable line_length

    static let sberpayPaymentMethodTitleKey = "Sberpay.paymentMethodTitle"

    enum Contract {
        static let nextKey = "Contract.next"
        static let feeKey = "Contract.fee"

        static let next = NSLocalizedString(
            "Contract.next",
            bundle: Bundle.framework,
            value: "Продолжить",
            comment: "Кнопка продолжить на контрактах https://yadi.sk/i/Ri9RjHDtilycWw"
        )
        static let fee = NSLocalizedString(
            "Contract.fee",
            bundle: Bundle.framework,
            value: "Включая комиссию",
            comment: "Текст на контракте `Включая комиссию` https://yadi.sk/i/Ri9RjHDtilycWw"
        )
    }

    enum PlaceholderView {
        static let buttonTitleKey = "Common.PlaceholderView.buttonTitle"
        static let textKey = "Common.PlaceholderView.text"

        static let buttonTitle = NSLocalizedString(
            "Common.PlaceholderView.buttonTitle",
            bundle: Bundle.framework,
            value: "Повторить",
            comment: "Текст кнопки на Placeholder `Повторить`"
        )
        static let text = NSLocalizedString(
            "Common.PlaceholderView.text",
            bundle: Bundle.framework,
            value: "Попробуйте повторить чуть позже.",
            comment: "Текст на Placeholder `Попробуйте повторить чуть позже.`"
        )
    }

    enum BankCardView {
        static let inputCvcHintKey = "BankCardView.inputCvcHint"
        static let inputCvcPlaceholderKey = "BankCardView.inputCvcPlaceholder"
        static let inputPanPlaceholderKey = "BankCardView.inputPanPlaceholder"
        static let inputPanPlaceholderWithoutScanKey = "BankCardView.inputPanPlaceholderWithoutScan"
        static let inputPanHintKey = "BankCardView.inputPanHint"
        static let inputExpiryDateHintKey = "BankCardView.inputExpiryDateHint"
        static let inputExpiryDatePlaceholderKey = "BankCardView.inputExpiryDatePlaceholder"

        static let inputPanHint = NSLocalizedString(
            "BankCardView.inputPanHint",
            bundle: Bundle.framework,
            value: "Номер карты",
            comment: "Текст `Номер карты` при вводе данных банковской карты https://yadi.sk/i/Z2oi1Uun7nS-jA"
        )
        static let inputPanPlaceholder = NSLocalizedString(
            "BankCardView.inputPanPlaceholder",
            bundle: Bundle.framework,
            value: "Введите или отсканируйте",
            comment: "Текст `Введите или отсканируйте` при вводе данных банковской карты https://yadi.sk/i/Z2oi1Uun7nS-jA"
        )
        static let inputPanPlaceholderWithoutScan = NSLocalizedString(
            "BankCardView.inputPanPlaceholderWithoutScan",
            bundle: Bundle.framework,
            value: "Введите",
            comment: "Текст `Введите` при вводе данных банковской карты в случае если сканирование не доступно https://yadi.sk/i/fbrtpMi0d-k4xw"
        )
        static let inputExpiryDateHint = NSLocalizedString(
            "BankCardView.inputExpiryDateHint",
            bundle: Bundle.framework,
            value: "Срок действия",
            comment: "Текст `Срок действия` при вводе данных банковской карты https://yadi.sk/i/qhizzdr8cAATsw"
        )
        static let inputExpiryDatePlaceholder = NSLocalizedString(
            "BankCardView.inputExpiryDatePlaceholder",
            bundle: Bundle.framework,
            value: "ММ/ГГ",
            comment: "Текст `ММ/ГГ` при вводе данных банковской карты https://yadi.sk/i/qhizzdr8cAATsw"
        )
        static let inputCvcHint = NSLocalizedString(
            "BankCardView.inputCvcHint",
            bundle: Bundle.framework,
            value: "Код",
            comment: "Текст `Код` при вводе данных банковской карты https://yadi.sk/i/qhizzdr8cAATsw"
        )
        static let inputCvcPlaceholder = NSLocalizedString(
            "BankCardView.inputCvcPlaceholder",
            bundle: Bundle.framework,
            value: "CVC",
            comment: "Текст `CVC` при вводе данных банковской карты https://yadi.sk/i/qhizzdr8cAATsw"
        )

        enum BottomHint {
            static let invalidCvcKey = "BankCardDataInputView.BottomHint.invalidCvc"

            static let invalidPan = NSLocalizedString(
                "BankCardDataInputView.BottomHint.invalidPan",
                bundle: Bundle.framework,
                value: "Проверьте номер карты",
                comment: "Текст `Проверьте номер карты` при вводе данных банковской карты https://yadi.sk/i/uDMEBEe3DqPboA"
            )
            static let invalidExpiry = NSLocalizedString(
                "BankCardDataInputView.BottomHint.invalidExpiry",
                bundle: Bundle.framework,
                value: "Проверьте месяц и год",
                comment: "Текст `Проверьте месяц и год` при вводе данных банковской карты https://yadi.sk/d/SbMd6T6aj3vyAw"
            )
            static let invalidCvc = NSLocalizedString(
                "BankCardDataInputView.BottomHint.invalidCvc",
                bundle: Bundle.framework,
                value: "Проверьте CVC",
                comment: "Текст `Проверьте CVC` при вводе данных банковской карты https://yadi.sk/i/A49itN4AH9BkHg"
            )
        }
    }

    enum Error {
        static let unknownKey = "Common.Error.unknown"
        static let unknown = NSLocalizedString(
            "Common.Error.unknown",
            bundle: Bundle.framework,
            value: "Что то пошло не так",
            comment: "Текст `Что то пошло не так` https://yadi.sk/i/JapUT2mTEVnTtw"
        )
    }

    enum Alert {
        static let okKey = "Common.button.ok"
        static let cancelKey = "Common.button.cancel"

        static let ok = NSLocalizedString(
            "Common.button.ok",
            bundle: Bundle.framework,
            value: "ОК",
            comment: "Текст `ОК` на Alert https://yadi.sk/i/68ImXb9rz31RkQ"
        )
        static let cancel = NSLocalizedString(
            "Common.button.cancel",
            bundle: Bundle.framework,
            value: "Отменить",
            comment: "Текст `Отменить` на Alert https://yadi.sk/i/68ImXb9rz31RkQ"
        )
    }

    enum SaveAuthInApp {
        static let titleKey = "Contract.format.saveAuthInApp.title"
        static let textKey = "Contract.format.saveAuthInApp"
        static let title = NSLocalizedString(
            "Contract.format.saveAuthInApp.title",
            bundle: Bundle.framework,
            value: "Запомнить меня",
            comment: "Текст `Запомнить меня` на экране `ЮMoney` или `Привязанная карта` https://yadi.sk/i/o89CnEUSmNsM7g"
        )
        static let text = NSLocalizedString(
            "Contract.format.saveAuthInApp",
            bundle: Bundle.framework,
            value: "В следующий раз не придётся входить в профиль ЮMoney — можно будет оплатить быстрее",
            comment: "Текст в пункте `Запомнить меня` на экране `ЮMoney` или `Привязанная карта` https://yadi.sk/i/o89CnEUSmNsM7g"
        )
    }

    enum SberPay {
        static let title = NSLocalizedString(
            "Sberpay.Contract.Title",
            bundle: Bundle.framework,
            value: "SberPay",
            comment: "Текст `SberPay` https://yadi.sk/i/T-XQGU9NaPMgKA"
        )
    }

    enum CardSettingsDetails {
        static let unbindKey = "card.details.unbind"
        static let moreInfoKey = "card.details.info.more"
        static let unwindKey = "card.details.unwind"
        static let yoocardUnbindDetailsKey = "card.details.yoocardUnbindDetails"
        static let unbindSuccessKey = "card.details.unbind.success"
        static let autopaymentPersistsKey = "card.details.autopaymentPersists"
        static let unbindFailKey = "card.details.unbind.fail"
        static let unbindInfoTitleKey = "card.details.info.unbind.title"
        static let unbindInfoDetailsKey = "card.details.info.unbind.details"

        static let unbind = NSLocalizedString(
            "card.details.unbind",
            bundle: Bundle.framework,
            value: "Отвязать карту",
            comment: "Текст `Отвязать карту` https://disk.yandex.ru/i/QNJyBrfP52vQOw"
        )
        static let autopaymentPersists = NSLocalizedString(
            "card.details.autopaymentPersists",
            bundle: Bundle.framework,
            value: "После отвязки карты останутся автосписания. Отменить их можно через службу поддержки магазина.",
            comment: "Текст, в информере, о сохранении автоплатежа https://disk.yandex.ru/i/QNJyBrfP52vQOw"
        )
        static let moreInfo = NSLocalizedString(
            "card.details.info.more",
            bundle: Bundle.framework,
            value: "Подробнее",
            comment: "Текст кнопки, в информере, ведущей в подробности https://disk.yandex.ru/i/QNJyBrfP52vQOw"
        )
        static let unwind = NSLocalizedString(
            "card.details.unwind",
            bundle: Bundle.framework,
            value: "Вернуться",
            comment: "Текст, ведущей назад, кнопки https://disk.yandex.ru/i/dcgivhF4QbURwA"
        )
        static let yoocardUnbindDetails = NSLocalizedString(
            "card.details.yoocardUnbindDetails",
            bundle: Bundle.framework,
            value: "Отвязать эту карту можно только в настройках кошелька",
            comment: "Текст, в информере, для карты привязанной к кошельку https://disk.yandex.ru/i/dcgivhF4QbURwA"
        )
        static let unbindInfoTitle = NSLocalizedString(
            "card.details.info.unbind.title",
            bundle: Bundle.framework,
            value: "Как отвязать карту от кошелька",
            comment: "Заголовок информации об отвязке карты https://disk.yandex.ru/i/59heYTl9Q4L2fA"
        )
        static let unbindInfoDetails = NSLocalizedString(
            "card.details.info.unbind.details",
            bundle: Bundle.framework,
            value: """
            Для этого зайдите в настройки кошелька на сайте или в приложении ЮMoney.
            В приложении: нажмите на свою аватарку, выберите «Банковские карты», смахните нужную карту влево и нажмите «Удалить».
            На сайте: перейдите в настройки кошелька, откройте вкладку «Привязанные карты», найдите нужную карту и нажмите «Отвязать».
            """,
            comment: "Текст информации об отвязке карты https://disk.yandex.ru/i/59heYTl9Q4L2fA"
        )
        static let unbindSuccess = NSLocalizedString(
            "card.details.unbind.success",
            bundle: Bundle.framework,
            value: "Карта %@ отвязана",
            comment: "Текст нотификации об успешной отвязке карты. Параметр - маска карты https://disk.yandex.ru/i/JWC70LuzuJSeEw"
        )
        static let unbindFail = NSLocalizedString(
            "card.details.unbind.fail",
            bundle: Bundle.framework,
            value: "Не удалось отвязать карту %@",
            comment: "Текст нотификации об ошибке отвязки карты. Параметр - маска карты https://disk.yandex.ru/i/QNJyBrfP52vQOw"
        )
    }

    enum RecurrencyAndSavePaymentData {

        enum Header {
            static let requiredSaveDataAndAutopaymentsHeader = NSLocalizedString(
                "RecurrencyAndSavePaymentData.header.saveDataAndAutopayments.required",
                bundle: Bundle.framework,
                value: "Разрешим автосписания и сохраним платёжные данные",
                comment: "Текст информера о неопциональном подключении автосписания и сохранении данных при платеже https://disk.yandex.ru/i/dcZY0utIfx634w"
            )
            static let requiredAutopaymentsHeader = NSLocalizedString(
                "RecurrencyAndSavePaymentData.header.autopayments.required",
                bundle: Bundle.framework,
                value: "Разрешим автосписания",
                comment: "Текст информера о неопциональном подключении автосписания при платеже https://disk.yandex.ru/i/dcZY0utIfx634w"
            )
            static let requiredSaveDataHeader = NSLocalizedString(
                "RecurrencyAndSavePaymentData.header.saveData.required",
                bundle: Bundle.framework,
                value: "Сохраним платёжные данные",
                comment: "Текст информера о неопциональном сохранении платёжных данных при платеже https://disk.yandex.ru/i/dcZY0utIfx634w"
            )

            static let optionalSaveDataAndAutopaymentsHeader = NSLocalizedString(
                "RecurrencyAndSavePaymentData.header.saveDataAndAutopayments.optional",
                bundle: Bundle.framework,
                value: "Разрешить автосписания и сохранить платёжные данные",
                comment: "Текст информера о опциональном подключении автосписания и сохранении данных при платеже https://disk.yandex.ru/i/dcZY0utIfx634w"
            )
            static let optionalAutopaymentsHeader = NSLocalizedString(
                "RecurrencyAndSavePaymentData.header.autopayments.optional",
                bundle: Bundle.framework,
                value: "Разрешить автосписания",
                comment: "Текст информера о опциональном подключении автосписания при платеже https://disk.yandex.ru/i/dcZY0utIfx634w"
            )
            static let optionalSaveDataHeader = NSLocalizedString(
                "RecurrencyAndSavePaymentData.header.saveData.optional",
                bundle: Bundle.framework,
                value: "Сохранить платёжные данные",
                comment: "Текст информера о опциональном сохранении платёжных данных при платеже https://disk.yandex.ru/i/dcZY0utIfx634w"
            )
        }

        enum Link {
            enum Optional {
                static let saveDataLink = NSLocalizedString(
                    "RecurrencyAndSavePaymentData.link.saveData.optional",
                    bundle: Bundle.framework,
                    value: "Магазин сохранит данные вашей карты — в следующий раз можно будет их не вводить",
                    comment: "Текст со ссылкой информации об опциональном сохранении платёжных данных при платеже https://disk.yandex.ru/i/dcZY0utIfx634w"
                )
                static let saveDataLinkInteractive = NSLocalizedString(
                    "RecurrencyAndSavePaymentData.link.interactive.saveData.optional",
                    bundle: Bundle.framework,
                    value: "сохранит данные вашей карты",
                    comment: "Интерактивная часть текста со ссылкой информации об опциональном сохранении платёжных данных при платеже https://disk.yandex.ru/i/dcZY0utIfx634w"
                )
                static let autopaymentsLink = NSLocalizedString(
                    "RecurrencyAndSavePaymentData.link.autopayments.optional",
                    bundle: Bundle.framework,
                    value: "После оплаты запомним эту карту: магазин сможет списывать деньги без вашего участия",
                    comment: "Текст со ссылкой информации об опциональном подключении автоплатежа при платеже https://disk.yandex.ru/i/dcZY0utIfx634w"
                )
                static let autopaymentsInteractive = NSLocalizedString(
                    "RecurrencyAndSavePaymentData.link.interactive.autopayments.optional",
                    bundle: Bundle.framework,
                    value: "списывать деньги без вашего участия",
                    comment: "Интерактивная часть текста со ссылкой информации об опциональном подключении автоплатежа при платеже https://disk.yandex.ru/i/dcZY0utIfx634w"
                )
                static let autopaymentsAndSaveDataLink = NSLocalizedString(
                    "RecurrencyAndSavePaymentData.link.autopaymentsAndSaveData.optional",
                    bundle: Bundle.framework,
                    value: "После оплаты магазин сохранит данные карты и сможет списывать деньги без вашего участия",
                    comment: "Текст со ссылкой информации об опциональном подключении автоплатежа и сохранения данных карты при платеже https://disk.yandex.ru/i/dcZY0utIfx634w"
                )
                static let autopaymentsAndSaveDataInteractive = NSLocalizedString(
                    "RecurrencyAndSavePaymentData.link.interactive.autopaymentsAndSaveData.optional",
                    bundle: Bundle.framework,
                    value: "сохранит данные карты и сможет списывать деньги без вашего участия",
                    comment: "Интерактивная часть текста со ссылкой информации об опциональном подключении автоплатежа и сохранения данных карты при платеже https://disk.yandex.ru/i/dcZY0utIfx634w"
                )
            }
            enum Required {
                static let saveDataLink = NSLocalizedString(
                    "RecurrencyAndSavePaymentData.link.saveData.required",
                    bundle: Bundle.framework,
                    value: "Магазин сохранит данные вашей карты — в следующий раз можно будет их не вводить",
                    comment: "Текст со ссылкой информации об опциональном сохранении платёжных данных при платеже https://disk.yandex.ru/i/dcZY0utIfx634w"
                )
                static let saveDataLinkInteractive = NSLocalizedString(
                    "RecurrencyAndSavePaymentData.link.interactive.saveData.required",
                    bundle: Bundle.framework,
                    value: "сохранит данные вашей карты",
                    comment: "Интерактивная часть текста со ссылкой информации об опциональном сохранении платёжных данных при платеже https://disk.yandex.ru/i/dcZY0utIfx634w"
                )
                static let autopaymentsLink = NSLocalizedString(
                    "RecurrencyAndSavePaymentData.link.autopayments.required",
                    bundle: Bundle.framework,
                    value: "Заплатив здесь, вы разрешаете привязать карту и списывать деньги без вашего участия",
                    comment: "Текст со ссылкой информации об опциональном подключении автоплатежа при платеже https://disk.yandex.ru/i/dcZY0utIfx634w"
                )
                static let autopaymentsInteractive = NSLocalizedString(
                    "RecurrencyAndSavePaymentData.link.interactive.autopayments.required",
                    bundle: Bundle.framework,
                    value: "списывать деньги без вашего участия",
                    comment: "Интерактивная часть текста со ссылкой информации об опциональном подключении автоплатежа при платеже https://disk.yandex.ru/i/dcZY0utIfx634w"
                )
                static let autopaymentsAndSaveDataLink = NSLocalizedString(
                    "RecurrencyAndSavePaymentData.link.autopaymentsAndSaveData.required",
                    bundle: Bundle.framework,
                    value: "Заплатив здесь, вы соглашаетесь сохранить данные карты и списывать деньги без вашего участия",
                    comment: "Текст со ссылкой информации об опциональном подключении автоплатежа и сохранения данных карты при платеже https://disk.yandex.ru/i/dcZY0utIfx634w"
                )
                static let autopaymentsAndSaveDataInteractive = NSLocalizedString(
                    "RecurrencyAndSavePaymentData.link.interactive.autopaymentsAndSaveData.required",
                    bundle: Bundle.framework,
                    value: "сохранить данные карты и списывать деньги без вашего участия",
                    comment: "Интерактивная часть текста со ссылкой информации об опциональном подключении автоплатежа и сохранения данных карты при платеже https://disk.yandex.ru/i/dcZY0utIfx634w"
                )
            }
        }
    }
    // swiftlint:enable line_length
}

func localizeString(_ key: String, comment: String? = nil) -> String {
    let value = NSLocalizedString(key, bundle: Bundle.framework, comment: comment ?? "")
    guard let preferredLanguage = YKSdk.shared.lang else {
        return value
    }
    if NSLocale.current.languageCode == preferredLanguage {
        // The key was found and the preferred language matches the current language.
        return value
    }
    guard
        let path = Bundle.framework.path(forResource: preferredLanguage, ofType: "lproj"),
        let bundle = Bundle(path: path)
    else {
        return value
    }
    return NSLocalizedString(key, bundle: bundle, comment: comment ?? "")
}
