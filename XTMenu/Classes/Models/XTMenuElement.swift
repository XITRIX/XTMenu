//
//  XTMenuElement.swift
//  UIMenu
//
//  Created by Даниил Виноградов on 30.04.2022.
//

import Foundation

public struct XTMenu {
    var title: String? = nil
    var elements: [XTMenuElement]

    public init(title: String? = nil, elements: [XTMenuElement]) {
        self.title = title
        self.elements = elements
    }
}

public enum XTMenuElement {
    case action(model: XTMenuAction)
    case separator

    func isSeparatorNeeded() -> Bool {
        switch self {
        case .action:
            return true
        case .separator:
            return false
        }
    }
}

public struct XTMenuAction {
    var title: String
    var action: (() -> ())? = nil

    public init(title: String, action: (() -> ())? = nil) {
        self.title = title
        self.action = action
    }
}
