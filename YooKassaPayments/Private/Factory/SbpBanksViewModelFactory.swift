import Foundation

enum SbpBanksViewModelFactoryAssembly {
    static func makeFactory() -> SbpBanksViewModelFactory {
        SbpBanksViewModelFactoryImpl()
    }
}

protocol SbpBanksViewModelFactory {
    func makeViewModels(_ sbpBanks: SbpBankList) -> [SbpBankCellViewModel]
}

final class SbpBanksViewModelFactoryImpl {}

extension SbpBanksViewModelFactoryImpl: SbpBanksViewModelFactory {

    func makeViewModels(_ sbpBanks: SbpBankList) -> [SbpBankCellViewModel] {
        var viewModels: [SbpBankCellViewModel] = []

        switch sbpBanks {
        case .priority(let banks):
            viewModels.append(contentsOf: banks.map(makePriorityBankViewModel))
            viewModels.append(.init(
                title: Localized.moreBanksTitle,
                actionType: .openBanksList,
                accessoryType: .disclosureIndicator
            ))
        case .all(let banks):
            viewModels.append(contentsOf: banks.map(makeOrdinaryBankViewModel))
        }

        return viewModels
    }

    private func makeOrdinaryBankViewModel(_ bank: SbpBank) -> SbpBankCellViewModel {
        return SbpBankCellViewModel(
            title: bank.localizedName,
            actionType: .openBank(bank.deeplink),
            accessoryType: .none
        )
    }

    private func makePriorityBankViewModel(_ bank: SbpBank) -> SbpBankCellViewModel {
        return SbpBankCellViewModel(
            title: bank.localizedName,
            actionType: .openPriorityBank(bank.deeplink),
            accessoryType: .none
        )
    }
}

// MARK: - Localization

private extension SbpBanksViewModelFactoryImpl {
    enum Localized {
        // swiftlint:disable:next superfluous_disable_command
        // swiftlint:disable line_length
        static let moreBanksTitle = NSLocalizedString(
            "SbpConfirmationView.moreBanksTitle",
            bundle: Bundle.framework,
            value: "Выбрать другой банк",
            comment: "Title ячейки для перехода в полный список банков СБП"
        )
        // swiftlint:enable line_length
    }
}
