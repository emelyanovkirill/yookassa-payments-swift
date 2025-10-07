import UIKit
internal import YooMoneyUI

enum ActionTitleTextDialogFactory {

    static func makeActionTitleTextDialog(output: ActionTitleTextDialogDelegate) -> ActionTitleTextDialog {
        let view = ActionTitleTextDialog()
        view.tintColor = CustomizationStorage.shared.mainScheme
        view.setStyles(ActionTitleTextDialog.Styles.fail)
        view.buttonTitle = localizeString(CommonLocalized.PlaceholderView.buttonTitleKey)
        view.text = localizeString(CommonLocalized.PlaceholderView.textKey)
        view.delegate = output
        return view
    }
}
