//
//  ViewController.swift
//  XTMenu
//
//  Created by Daniil Vinogradov on 05/01/2022.
//  Copyright (c) 2022 Daniil Vinogradov. All rights reserved.
//

import UIKit
import XTMenu

class ViewController: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isToolbarHidden = false

        tableView.rowHeight = 64
        tableView.allowsSelection = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")

        tableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap(_:))))
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        50
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = "Tap anywhere! Tap anywhere! Tap anywhere!"
        return cell
    }

    @IBAction func menuAction(_ sender: UIBarButtonItem) {
        showMenu(with: sender.superview!.convert(sender.frame!, to: .none))
    }

    @objc func tap(_ tapGesture: UITapGestureRecognizer) {
        let point = tapGesture.location(in: view.superview)
        showMenu(with: CGRect(origin: point, size: .zero))
    }

    func showMenu(with anchor: CGRect) {
        var elements: [XTMenuElement] = []
        for i in 0 ..< 6 {
            elements.append(.action(model: .init(title: "Menu # \(i + 1)")))
        }

        elements.append(contentsOf: [.separator, .action(model: .init(title: "Menu"))])

        let menu = XTMenuController(menu: .init(title: "Main menu", elements: elements), anchorRect: anchor)

        if let presented = presentedViewController {
            presented.dismiss(animated: false)
        } else {
            present(menu, animated: true)
        }
    }
}

extension UIBarButtonItem {
    var view: UIView? {
        guard let view = value(forKey: "view") as? UIView else {
            return nil
        }
        return view
    }

    var superview: UIView? {
        view?.superview
    }

    var frame: CGRect? {
        view?.frame
    }
}
