//
//  MenuSeparator.swift
//  UIMenu
//
//  Created by Даниил Виноградов on 30.04.2022.
//

import UIKit

class XTMenuSeparatorCell: UITableViewCell {
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = separatorColor
    }
}

private extension XTMenuSeparatorCell {
    var separatorColor: UIColor {
        if #available(iOS 13, *) {
            return UIColor(dynamicProvider: { trait in
                switch trait.userInterfaceStyle {
                case .light:
                    return UIColor(white: 0, alpha: 0.08)
                case .dark:
                    return UIColor(white: 0, alpha: 0.16)
                default:
                    return UIColor(white: 0, alpha: 0.08)
                }
            })
        } else {
            return UIColor(white: 0, alpha: 0.08)
        }
    }
}
