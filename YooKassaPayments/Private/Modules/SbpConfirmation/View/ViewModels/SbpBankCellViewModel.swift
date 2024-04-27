import UIKit

struct SbpBankCellViewModel {
    let title: String
    let actionType: SbpBankCellActionType
    let accessoryType: UITableViewCell.AccessoryType
}

enum SbpBankCellActionType {
    case openBank(URL)
    case openPriorityBank(URL)
    case openBanksList
}
