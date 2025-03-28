internal import MoneyAuth
import YooMoneyPinning

enum MoneyAuthAssembly {
    static func makeMoneyAuthConfig(
        moneyAuthClientId: String,
        loggingEnabled: Bool
    ) -> MoneyAuth.Config {
        let keyValueStorage = KeyValueStoringAssembly.makeUserDefaultsStorage()
        let isDevHost = (try? keyValueStorage.readValue(for: Settings.Keys.devHost)) ?? false
        let authenticationChallengeIgnored = (try? keyValueStorage.readValue(
            for: Settings.Keys.authenticationChallengeIgnored
        )) ?? false

        let authenticationChallengeHandler = AuthenticationChallengeHandlerFactory.makeHandler(
            host: makeHost(),
            isDevHost: isDevHost,
            isLoggingEnabled: loggingEnabled,
            isAuthenticationChallengeIgnored: authenticationChallengeIgnored
        )

        let moneyAuthClientId = makeMoneyAuthClientId(
            currentClientId: moneyAuthClientId,
            isDevHost: isDevHost
        )

        let config = MoneyAuth.Config(
            origin: .wallet,
            clientId: moneyAuthClientId,
            host: makeHost(),
            isDevHost: isDevHost,
            loggingEnabled: loggingEnabled,
            authenticationChallengeHandler: authenticationChallengeHandler.process,
            supportEmail: "support@yoomoney.ru",
            supportPhone: "8 800 250-66-99",
            // swiftlint:disable:next force_unwrapping
            supportHelpUrl: URL(string: "https://yoomoney.ru/page?id=536720")!,
            apiVersion: .v1
        )
        return config
    }

    static func makeMoneyAuthCustomization() -> MoneyAuth.Customization {
        let configStorage = KeyValueStoringAssembly.makeSettingsStorage()
        let config: Config = (try? configStorage.readValue(for: StorageKeys.configKey))
            ?? ConfigMediatorImpl.defaultConfig

        let password = Customization.Password(
            restorePasswordEnabled: Constants.restorePasswordEnabled,
            showPasswordRecoverySuccess: true)

        let userAgreement = Customization.UserAgreement(
            title: config.userAgreementUrl,
            boundEmailTitle: nil
        )

        let email = Customization.Email(
            checkboxVisible: Constants.emailCheckboxVisible,
            checkboxTitle: Localized.emailCheckboxTitle,
            addEmailTitle: Localized.addEmailTitle
        )

        let customization = MoneyAuth.Customization(
            password: password,
            userAgreement: userAgreement,
            email: email,
            social: Customization.Social(),
            setUpPhone: nil,
            confirmPhone: Customization.ConfirmScreen(infoButtonHidden: true),
            confirmEmail: Customization.ConfirmEmail(),
            enterPhone: Customization.EnterPhone()
        )

        return customization
    }

    private static func makeHost() -> String {
        let hostProvider = HostProviderAssembly.makeHostProvider()
        let _host = try? hostProvider.host(
            for: GlobalConstants.Hosts.moneyAuth
        )
        guard let host = _host else {
            assertionFailure("Unknown host for key \(GlobalConstants.Hosts.moneyAuth)")
            return ""
        }
        return host
    }

    private static func makeMoneyAuthClientId(
        currentClientId: String,
        isDevHost: Bool
    ) -> String {
        guard isDevHost == false else {
            return "a90r00nd74uqa4f1jbp6dni0tmf9eg6s"
        }
        return currentClientId
    }
}

// MARK: - Constants

private extension MoneyAuthAssembly {
    enum Constants {
        // swiftlint:disable line_length
        static let restorePasswordEnabled = false
        static let emailCheckboxVisible = false
        // swiftlint:enable line_length
    }
}

// MARK: - Localized

private extension MoneyAuthAssembly {
    enum Localized {
        // swiftlint:disable line_length
        static let userAgreementTitle = NSLocalizedString(
            "Wallet.Authorization.userAgreementTitle",
            bundle: Bundle.framework,
            value: "Нажимая кнопку, я подтверждаю осведомлённость и согласие <a href=\\\"https://yoomoney.ru/page?id=525698%5C\\\">со всеми юридическими условиями</a> и с тем, что если я не подключу информирование об операциях на почту или телефон, единственным каналом информирования будет история моих операций — на сайте и в приложении ЮMoney",
            comment: "Текст на экране про миграцию, который после нажатия на немигрированный аккаунт на экране выбора аккаунта https://yadi.sk/i/_IMGLswOravIOw"
        )
        static let userWithEmailAgreementTitle = NSLocalizedString(
            "Wallet.Authorization.userWithEmailAgreementTitle",
            bundle: Bundle.framework,
            value: "Нажимая кнопку, я подтверждаю осведомлённость и согласие <a href=\\\"https://yoomoney.ru/page?id=525698%5C\\\">со всеми юридическими условиями</a>",
            comment: "Текст с ссылкой под кнопкой на экране про миграцию, который после нажатия на немигрированный аккаунт на экране выбора аккаунта https://yadi.sk/i/_IMGLswOravIOw"
        )
        static let emailCheckboxTitle = NSLocalizedString(
            "Wallet.Authorization.emailCheckboxTitle",
            bundle: Bundle.framework,
            value: "Хочу получать новости сервиса, скидки, опросы: максимум раз в неделю",
            comment: "Текст условий сервиса с ссылкой на экране установки пароля для пользователя c установленной почтой https://yadi.sk/i/DgL-5V4hQL15WQ"
        )
        static let addEmailTitle = NSLocalizedString(
            "Wallet.Authorization.addEmailTitle",
            bundle: Bundle.framework,
            value: "Для чеков и уведомлений",
            comment: "Текст условий сервиса с ссылкой на экране установки пароля для пользователя без установленной почты https://yadi.sk/i/DgL-5V4hQL15WQ"
        )
        // swiftlint:enable line_length
    }
}
