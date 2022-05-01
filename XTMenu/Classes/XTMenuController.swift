//
//  MenuController.swift
//  UIMenu
//
//  Created by Даниил Виноградов on 29.04.2022.
//

import UIKit

public class XTMenuController: UIViewController {
    private let menuWidth: CGFloat = 250
    private let borderOffset: CGFloat = 8

    private let whierdTouchOffset: CGFloat = 0
    private let tableView: UITableView = .init(frame: .zero)
    private var heightConstraint: NSLayoutConstraint!
    private var heightConstant: CGFloat = 0

    private var container: UIView!
    private var containerFrame: CGRect!
    private var appearAnimator: UIViewPropertyAnimator!
    private var currentlySelectedCell: IndexPath?
    private var lastScale: CGFloat = -1

    private var dismissed = false

    private var anchorRect: CGRect
    private var menu: XTMenu

    public init(menu: XTMenu, anchorRect: CGRect) {
        self.anchorRect = anchorRect
        self.menu = menu
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override var modalPresentationStyle: UIModalPresentationStyle {
        get { .custom }
        set {}
    }

    public override var transitioningDelegate: UIViewControllerTransitioningDelegate? {
        get { self }
        set {}
    }

    public override var modalTransitionStyle: UIModalTransitionStyle {
        get { .crossDissolve }
        set {}
    }

    public override func loadView() {
        view = XTMenuUnderlayView()
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        if let delegateView = view as? XTMenuUnderlayView {
            delegateView.touchDelegate = presentingViewController?.view
            delegateView.menuController = self
        }

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizer(_:)))
        view.addGestureRecognizer(panGesture)

        container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(container)

        container.center = super.view.center
        container.clipsToBounds = false

        heightConstraint = container.heightAnchor.constraint(equalToConstant: 0)

        NSLayoutConstraint.activate([
            heightConstraint,
            container.widthAnchor.constraint(equalToConstant: menuWidth),
        ])

        let menuViewContainer: UIVisualEffectView
        if #available(iOS 13.0, *) {
            menuViewContainer = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
        } else {
            menuViewContainer = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        }
        menuViewContainer.frame = container.bounds
        menuViewContainer.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        container.addSubview(menuViewContainer)

        menuViewContainer.layer.cornerRadius = 12
        if #available(iOS 13.0, *) {
            menuViewContainer.layer.cornerCurve = .continuous
        }
        menuViewContainer.clipsToBounds = true

        tableView.frame = menuViewContainer.bounds
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        menuViewContainer.contentView.addSubview(tableView)

        tableView.register(UINib(nibName: "XTMenuCell", bundle: Bundle(for: Self.self)), forCellReuseIdentifier: "XTMenuCell")
        tableView.register(UINib(nibName: "XTMenuSeparatorCell", bundle: Bundle(for: Self.self)), forCellReuseIdentifier: "XTMenuSeparatorCell")
        tableView.register(XTMenuHeader.self, forHeaderFooterViewReuseIdentifier: "XTMenuHeader")

        tableView.backgroundColor = .clear
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.sectionHeaderHeight = .leastNonzeroMagnitude
        tableView.estimatedRowHeight = 44
        tableView.estimatedSectionHeaderHeight = .leastNonzeroMagnitude

        tableView.isScrollEnabled = false

        tableView.dataSource = self
        tableView.delegate = self

        appearAnimator = UIViewPropertyAnimator(duration: 0.6, dampingRatio: 0.7)
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        container.alpha = 0
        container.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        appearAnimator.addAnimations { [self] in
            container.alpha = 1
            container.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
        appearAnimator.startAnimation()
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        recalculateSize()
        calculateAnchor()
    }

    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        dismiss(animated: false)
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        recalculateSize()
    }

    @objc func dismissSelf() {
        guard !dismissed else { return }
        dismissed = true

        container.layer.removeAllAnimations()

        appearAnimator.stopAnimation(true)
        appearAnimator.finishAnimation(at: .current)

        appearAnimator.addAnimations { [self] in
            container.alpha = 0
            container.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        }

        appearAnimator.addCompletion { [self] _ in
            dismiss(animated: true)
        }

        appearAnimator.startAnimation()
    }
}

private extension XTMenuController {
    func recalculateSize() {
        heightConstant = tableView.contentSize.height
        heightConstraint.constant = heightConstant

        containerFrame = container.frame
        setupShadow()
    }

    func setupShadow() {
        container.layer.shadowPath = UIBezierPath(roundedRect: container.bounds, cornerRadius: container.layer.cornerRadius).cgPath
        container.layer.shadowRadius = 80
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOpacity = 0.3
    }

    func calculateAnchor() {
        let minOff = anchorRect.midX - menuWidth / 2
        let maxOff = anchorRect.midX + menuWidth / 2

        var xAnchor = 0.5

        if minOff < 0 {
            xAnchor += (minOff - borderOffset) / menuWidth
        } else if maxOff > view.window?.frame.width ?? 0 {
            xAnchor += (maxOff - (view.window?.frame.width ?? 0) + borderOffset) / menuWidth
        }

        if anchorRect.minY > (view.window?.frame.height ?? 0) - anchorRect.maxY {
            container.layer.anchorPoint = .init(x: xAnchor, y: 1)

            NSLayoutConstraint.activate([
                container.centerXAnchor.constraint(equalTo: view.leftAnchor, constant: anchorRect.midX),
                container.centerYAnchor.constraint(equalTo: view.topAnchor, constant: anchorRect.minY - borderOffset),
            ])
        } else {
            container.layer.anchorPoint = .init(x: xAnchor, y: 0)

            NSLayoutConstraint.activate([
                container.centerXAnchor.constraint(equalTo: view.leftAnchor, constant: anchorRect.midX),
                container.centerYAnchor.constraint(equalTo: view.topAnchor, constant: anchorRect.maxY + borderOffset),
            ])
        }

        view.layoutIfNeeded()
    }

    @objc func panGestureRecognizer(_ sender: UIPanGestureRecognizer) {
        let rawPoint = sender.location(in: .none)
        let point = CGPoint(x: rawPoint.x - containerFrame.origin.x, y: rawPoint.y - containerFrame.origin.y - whierdTouchOffset)

        let view = container.hitTest(point, with: nil)

        if let cell = view as? UITableViewCell,
           let indexPath = tableView.indexPath(for: cell)
        {
            if currentlySelectedCell != indexPath {
                currentlySelectedCell = indexPath
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        } else if view == nil || view is UITableView,
                  let selected = tableView.indexPathForSelectedRow
        {
            tableView.deselectRow(at: selected, animated: false)
        }

        let maxDistance: CGFloat = 160

        var out: CGFloat = 0
        if sender.state == .changed {
            var xOut: CGFloat = 0
            if point.x < 0 { xOut = abs(point.x) }
            else if point.x > containerFrame.width { xOut = point.x - containerFrame.width }

            var yOut: CGFloat = 0
            if point.y < 0 { yOut = abs(point.y) }
            else if point.y > containerFrame.height { yOut = point.y - containerFrame.height }

            out = min(max(0, max(xOut, yOut)), maxDistance)
        }

        if sender.state == .ended {
            out = 0
            if let selected = tableView.indexPathForSelectedRow,
               case .action(let model) = menu.elements[selected.row]
            {
                model.action?()
                dismissSelf()
            }
        }

        let scale = (1 - (out / maxDistance)) * 0.4 + 0.6
        if lastScale != scale {
            lastScale = scale
            UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseOut, .allowUserInteraction]) { [self] in
                container.transform = CGAffineTransform(scaleX: scale, y: scale)
            }
        }
    }
}

extension XTMenuController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        menu.elements.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let element = menu.elements[indexPath.row]
        switch element {
        case .action(model: let model):
            let cell = tableView.dequeueReusableCell(withIdentifier: "XTMenuCell", for: indexPath) as! XTMenuCell
            cell.setup(with: model.title)
            cell.separatorIsHidden = !(menu.elements.getItem(at: indexPath.row + 1)?.isSeparatorNeeded() ?? true) ||
                indexPath.row >= menu.elements.count - 1
            return cell
        case .separator:
            return tableView.dequeueReusableCell(withIdentifier: "XTMenuSeparatorCell", for: indexPath) as! XTMenuSeparatorCell
        }
    }
}

extension XTMenuController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let title = menu.title else { return nil }

        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "XTMenuHeader") as! XTMenuHeader
        header.titleText = title
        return header
    }

    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let title = menu.title,
              !title.isEmpty
        else { return 0 }

        return UITableView.automaticDimension
    }

    public func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        currentlySelectedCell = indexPath
        return true
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if case .action(let model) = menu.elements[indexPath.row] {
            model.action?()
        }
        dismissSelf()
    }
}

extension XTMenuController: UIViewControllerTransitioningDelegate {
    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        PresentationController(presentedViewController: presented, presenting: presenting)
    }

    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        XTMenuAnimator(presenting: true)
    }

    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        XTMenuAnimator(presenting: false)
    }
}

class PresentationController: UIPresentationController {
    override var frameOfPresentedViewInContainerView: CGRect {
        let bounds = containerView!.bounds
        return CGRect(x: 0,
                      y: 0,
                      width: bounds.width,
                      height: bounds.height)
    }

    override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()
        containerView?.addSubview(presentedView!)
    }

    override func containerViewDidLayoutSubviews() {
        super.containerViewDidLayoutSubviews()
        presentedView?.frame = frameOfPresentedViewInContainerView
    }
}

private extension Array {
    func getItem(at index: Int) -> Element? {
        guard index < count else { return nil }
        return self[index]
    }
}

private extension UIWindow {
    static var key: UIWindow? {
        if #available(iOS 13, *) {
            return UIApplication.shared.connectedScenes
                .filter { $0.activationState == .foregroundActive }
                .compactMap { $0 as? UIWindowScene }
                .first?.windows
                .filter { $0.isKeyWindow }.first
        } else {
            return UIApplication.shared.keyWindow
        }
    }
}
