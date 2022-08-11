import UIKit
import YooMoneyUI

extension UINavigationItem {

    enum Styles {
        static let onlySmallTitle = YooMoneyUI.Style(name: "onlySmallTitle") { (navigationItem: UINavigationItem) in
            if #available(iOS 11.0, *) {
                navigationItem.largeTitleDisplayMode = .never
            }
        }
    }
}
