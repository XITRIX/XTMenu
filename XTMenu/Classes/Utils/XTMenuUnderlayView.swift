//
//  TouchDelegatingView.swift
//  UIMenu
//
//  Created by Даниил Виноградов on 30.04.2022.
//

import UIKit

class XTMenuUnderlayView: UIView {
    weak var menuController: XTMenuController?
    weak var touchDelegate: UIView?

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let view = super.hitTest(point, with: event)
        else { return nil }

//        print(view.self)

        guard self === view,
              let point = touchDelegate?.convert(point, from: self)
        else { return view }

        menuController?.dismissSelf()
        return touchDelegate?.hitTest(point, with: event)
    }
}
