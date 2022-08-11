/* The MIT License
 *
 * Copyright © 2022 NBCO YooMoney LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit
import YooMoneyUI

// MARK: - Styles
extension UIButton {

    enum Styles {
        /// Generate rounded image for button background.
        static func roundedBackground(color: UIColor, cornerRadius: CGFloat = 0) -> UIImage {
            let side = cornerRadius * 2 + 2
            let size = CGSize(width: side, height: side)
            return UIImage.image(color: color)
                .scaled(to: size)
                .rounded(cornerRadius: cornerRadius)
                .resizableImage(
                    withCapInsets: UIEdgeInsets(
                        top: cornerRadius,
                        left: cornerRadius,
                        bottom: cornerRadius,
                        right: cornerRadius
                    )
                )
        }

        // MARK: - Background images

        fileprivate static let cornerRadius: CGFloat = 6

        fileprivate static let lightGoldBackgroundRounded6 = roundedBackground(
            color: .lightGold,
            cornerRadius: cornerRadius
        )
        fileprivate static let galleryBackgroundRounded6 = roundedBackground(
            color: .gallery,
            cornerRadius: cornerRadius
        )
        fileprivate static let dandelionBackgroundRounded6 = roundedBackground(
            color: .dandelion,
            cornerRadius: cornerRadius
        )
        fileprivate static let dandelion80BackgroundRounded6 = roundedBackground(
            color: .dandelion80,
            cornerRadius: cornerRadius
        )
        fileprivate static let mercuryBackgroundRounded6 = roundedBackground(
            color: .mercury,
            cornerRadius: cornerRadius
        )
        fileprivate static let mustardBackgroundRounded6 = roundedBackground(
            color: .mustard,
            cornerRadius: cornerRadius
        )
        fileprivate static let creamBruleeBackgroundRounded6 = roundedBackground(
            color: .creamBrulee,
            cornerRadius: cornerRadius
        )
        fileprivate static let dandelionBackground = roundedBackground(color: .dandelion)
        fileprivate static let dandelion80Background = roundedBackground(color: .dandelion80)
        fileprivate static let galleryBackground = roundedBackground(color: .gallery)
        fileprivate static let mercuryBackground = roundedBackground(color: .mercury)
    }
}

extension UIButton {

    private func setColorizedImage(_ image: UIImage, color: UIColor, for state: UIControl.State) {
        let colorizedImage = image.colorizedImage(color: color)
        self.setImage(colorizedImage, for: state)
    }

    var style: Style {
        Style(target: self)
    }

    struct Style {
        let target: UIButton

        @discardableResult
        func submitHeight() -> Style {
            NSLayoutConstraint.activate([target.heightAnchor.constraint(equalToConstant: 56)])
            return self
        }

        @discardableResult
        func submitText(color: UIColor) -> Style {
            target.setTitleColor(color, for: .normal)
            target.setTitleColor(.highlighted(from: color), for: .highlighted)
            target.setTitleColor(disabledBackgroundColor, for: .disabled)
            target.tintColor = color
            target.titleLabel?.lineBreakMode = .byTruncatingTail
            target.titleLabel?.font = UIFont.dynamicBodySemibold
            target.contentEdgeInsets.left = Space.double
            target.contentEdgeInsets.right = Space.double
            return self
        }

        @discardableResult
        func submit(colored: UIColor = CustomizationStorage.shared.mainScheme, ghostTint: Bool = false) -> Style {
            return submitText(color: colored).submitHeight().colored(target.tintColor, ghostTint: ghostTint)
        }

        @discardableResult
        func submitAlert(ghostTint: Bool) -> Style {
            return submitText(color: .redOrange).colored(.redOrange, ghostTint: ghostTint).submitHeight()
        }

        @discardableResult
        func cancel() -> Style { submitHeight().submitText(color: UIColor.AdaptiveColors.primary) }

        private var disabledBackgroundColor: UIColor {
            if #available(iOS 13.0, *) {
                return .systemGray5
            } else {
                return .mousegrey
            }
        }

        @discardableResult
        func colored(_ color: UIColor, ghostTint: Bool = false) -> Style {
            let hColor = UIColor.highlighted(from: color)
            target.tintColor = color

            if ghostTint {
                [
                    (color, UIControl.State.normal),
                    (hColor, .highlighted),
                    (disabledBackgroundColor, .disabled),
                ].forEach {
                    target.setTitleColor($0.0, for: $0.1)
                    target.setBackgroundImage(
                        Styles.roundedBackground(color: .ghostTint(from: $0.0), cornerRadius: Styles.cornerRadius),
                        for: $0.1)

                }
            } else {
                target.setTitleColor(.white, for: .normal)
                target.setTitleColor(.white, for: .highlighted)
                target.setTitleColor(disabledBackgroundColor, for: .disabled)
                [
                    (color, UIControl.State.normal),
                    (hColor, .highlighted),
                    (disabledBackgroundColor, .disabled),
                ].forEach {
                    target.setBackgroundImage(
                        Styles.roundedBackground(color: $0.0, cornerRadius: Styles.cornerRadius),
                        for: $0.1
                    )
                }
            }

            return self
        }
    }

    enum DynamicStyle {
        /// Style for secondary link button.
        static let secondaryLink = YooMoneyUI.Style(name: "button.dynamic.secondaryLink") { (button: UIButton) in
            button.titleLabel?.lineBreakMode = .byTruncatingTail

            let font = UIFont.dynamicBody
            let color = UIColor.doveGray

            let colors: [(UIControl.State, UIColor)] = [
                (.normal, color),
                (.highlighted, .highlighted(from: color)),
                (.disabled, .nobel),
            ]

            colors.forEach { (state, textColor) in
                guard let text = button.title(for: state) else { return }
                let attributedString = NSAttributedString(string: text, attributes: [
                    .foregroundColor: textColor,
                    .font: font,
                ])
                button.setAttributedTitle(attributedString, for: state)
            }
        }
    }
}

// MARK: - Constants
private extension UIButton {
    enum Constants {
        static let tagButtonHeight: CGFloat = Space.triple
    }
}
