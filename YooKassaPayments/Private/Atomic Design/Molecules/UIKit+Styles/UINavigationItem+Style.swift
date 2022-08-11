import UIKit
import YooMoneyUI

// MARK: - Styles
extension UINavigationItem {

    enum Styles {
        static let onlySmallTitle = Style(name: "onlySmallTitle") { (navigationItem: UINavigationItem) in
            if #available(iOS 11.0, *) {
                navigationItem.largeTitleDisplayMode = .never
            }
        }
    }
}
