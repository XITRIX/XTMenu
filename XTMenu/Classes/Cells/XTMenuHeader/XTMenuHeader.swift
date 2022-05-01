//
//  XTMenuHeader.swift
//  UIMenu
//
//  Created by Даниил Виноградов on 30.04.2022.
//

import UIKit

class XTMenuHeader: UITableViewHeaderFooterView {
    private let title = UILabel(frame: .zero)

    var titleText: String {
        get { title.text ?? "" }
        set { title.text = newValue }
    }

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        isUserInteractionEnabled = false

        title.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 13.0, *) {
            title.textColor = .secondaryLabel
        } else {
            title.textColor = UIColor(displayP3Red: 60/255, green: 60/255, blue: 67/255, alpha: 0.6)
        }
        title.textAlignment = .center
        title.font = UIFont.systemFont(ofSize: 12)
        addSubview(title)

        NSLayoutConstraint.activate([
            title.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            title.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            trailingAnchor.constraint(equalTo: title.trailingAnchor, constant: 12),
            bottomAnchor.constraint(equalTo: title.bottomAnchor, constant: 10),
        ])

        let separator: UIVisualEffectView
        if #available(iOS 13.0, *) {
            separator = UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: UIBlurEffect(style: .systemMaterial), style: .separator))
        } else {
            separator = UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: UIBlurEffect(style: .light)))
        }
        separator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(separator)

        NSLayoutConstraint.activate([
            separator.heightAnchor.constraint(equalToConstant: 0.3),
            separator.leadingAnchor.constraint(equalTo: leadingAnchor),
            trailingAnchor.constraint(equalTo: separator.trailingAnchor),
            bottomAnchor.constraint(equalTo: separator.topAnchor),
        ])

        let subseparator = UIView(frame: separator.bounds)
        subseparator.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        subseparator.backgroundColor = .white
        separator.contentView.addSubview(subseparator)
    }
}
