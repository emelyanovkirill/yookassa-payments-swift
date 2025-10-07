import UIKit

final class CardSettingsPresenter: CardSettingsViewOutput, CardSettingsInteractorOutput {
    weak var view: CardSettingsViewInput!
    weak var output: CardSettingsModuleOutput!

    var interactor: CardSettingsInteractorInput!
    var router: CardSettingsRouterInput!

    private let paymentMethodViewModelFactory: PaymentMethodViewModelFactory
    private let savePaymentMethodOptionTexts: Config.SavePaymentMethodOptionTexts
    private let data: CardSettingsModuleInputData

    init(
        data: CardSettingsModuleInputData,
        paymentMethodViewModelFactory: PaymentMethodViewModelFactory,
        savePaymentMethodOptionTexts: Config.SavePaymentMethodOptionTexts
    ) {
        self.data = data
        self.paymentMethodViewModelFactory = paymentMethodViewModelFactory
        self.savePaymentMethodOptionTexts = savePaymentMethodOptionTexts
    }

    func setupView() {
        let canUnbind: Bool
        let displayName: String
        let cardTitle: String
        let cardMaskHint: String
        switch data.card {
        case .yoomoney(let name):
            displayName = name ?? data.cardMask
            cardTitle = name ?? localizeString(PaymentMethodResources.Localized.yooMoneyCardKey)
            canUnbind = false
            cardMaskHint = PaymentMethodResources.Localized.yooMoneyCard
            view.hideSubmit(true)
            interactor.track(event: .screenUnbindCard(cardType: .wallet))
        case .card(let name, _):
            displayName = name
            cardTitle = localizeString(PaymentMethodResources.Localized.linkedCardKey)
            canUnbind = true
            cardMaskHint = localizeString(PaymentMethodResources.Localized.bankCardKey)
            view.hideSubmit(false)
            interactor.track(event: .screenUnbindCard(cardType: .bankCard))
        }

        view.set(
            title: displayName,
            cardMaskHint: cardMaskHint,
            cardLogo: data.cardLogo,
            cardMask: paymentMethodViewModelFactory.replaceBullets(data.cardMask.splitEvery(4, separator: " ")),
            cardTitle: cardTitle,
            informerMessage: data.infoText,
            canUnbind: canUnbind
        )
    }

    func didPressSubmit() {
        view.disableSubmit()
        switch data.card {
        case .yoomoney:
            output.cardSettingsModuleDidCancel()
        case .card(_, let id):
            view.showActivity()

            DispatchQueue.global().async { [weak self] in
                guard let self = self else { return }
                self.interactor.unbind(id: id)
            }

        }
    }
    func didPressCancel() {
        output.cardSettingsModuleDidCancel()
    }
    func didPressInformerMoreInfo() {
        switch data.card {
        case .yoomoney:
            router.openInfo(
                title: localizeString(CommonLocalized.CardSettingsDetails.unbindInfoTitleKey),
                details: localizeString(CommonLocalized.CardSettingsDetails.unbindInfoDetailsKey)
            )
            interactor.track(event: .screenDetailsUnbindWalletCard)
        case .card:
            router.openInfo(
                title: HTMLUtils.htmlOut(source: savePaymentMethodOptionTexts.screenRecurrentOnSberpayTitle),
                details: HTMLUtils.htmlOut(source: savePaymentMethodOptionTexts.screenRecurrentOnSberpayText)
            )
        }
    }

    // MARK: - CardSettingsInteractorOutput

    func didFailUnbind(error: Error, id: String) {
        interactor.track(event: .actionUnbindBankCard(success: false))
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.view.hideActivity()
            self.view.enableSubmit()
            self.view.presentError(
                with: String(
                    format: localizeString(CommonLocalized.CardSettingsDetails.unbindFailKey),
                    self.data.cardMask
                )
            )
        }
    }

    func didUnbind(id: String) {
        interactor.track(event: .actionUnbindBankCard(success: true))
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.view.enableSubmit()
            self.view.hideActivity()
            self.output.cardSettingsModuleDidUnbindCard(mask: self.data.cardMask)
        }
    }
}
