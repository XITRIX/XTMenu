//
//  XTMenuCell.swift
//  UIMenu
//
//  Created by Даниил Виноградов on 30.04.2022.
//

import UIKit

class XTMenuCell: UITableViewCell {
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var separatorView: UIVisualEffectView!

    override func awakeFromNib() {
        super.awakeFromNib()

        let blur: UIVisualEffectView
        if #available(iOS 13.0, *) {
            blur = UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: UIBlurEffect(style: .systemMaterial), style: .tertiaryFill))
        } else {
            blur = UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: UIBlurEffect(style: .light)))
        }
        blur.contentView.backgroundColor = .white
        selectedBackgroundView = blur
    }

    func setup(with text: String) {
        titleLabel.text = text
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        selectedBackgroundView?.frame = contentView.frame.inset(by: UIEdgeInsets(top: 0.3, left: 0, bottom: 0, right: 0))
//        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0))
    }
}

extension XTMenuCell: CellWithSeparator {
    var separatorIsHidden: Bool {
        get { separatorView.isHidden }
        set { separatorView.isHidden = newValue }
    }
}
