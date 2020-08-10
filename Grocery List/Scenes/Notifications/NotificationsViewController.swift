//
//  NotificationsViewController.swift
//  Grocery List
//
//  Created by Joe Benton on 16/07/2020.
//  Copyright © 2020 Joe Benton. All rights reserved.
//

import UIKit
import SwipeCellKit

class NotificationsViewController: UIViewController, StoryboardBased, ViewModelBased {

    var viewModel: NotificationsViewModel? {
        didSet {
            viewModel?.viewController = self
        }
    }
    
    var overlayLoader: OverlayLoader?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configTableView()
    }
    
    fileprivate func configTableView() {
        tableView.estimatedRowHeight = 60
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView()
        
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 40, right: 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel?.viewReady()
        
        configureNavBarStyle()
    }
    
    fileprivate func configureNavBarStyle() {
        let compactAppearance = UINavigationBarAppearance()
        compactAppearance.configureWithDefaultBackground()
        let compactButtonAppearance = UIBarButtonItemAppearance(style: .plain)
        compactButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor(named: "zenBlue")!]
        compactAppearance.buttonAppearance = compactButtonAppearance
        
        let largeAppearance = UINavigationBarAppearance()
        largeAppearance.configureWithTransparentBackground()
        let largeButtonAppearance = UIBarButtonItemAppearance(style: .plain)
        largeButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor(named: "zenBlue")!]
        largeAppearance.buttonAppearance = largeButtonAppearance
        largeAppearance.largeTitleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor(named: "zenBlack")!,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 28, weight: .bold)
        ]
        
        navigationController?.navigationBar.standardAppearance = compactAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = largeAppearance
    }
    
    func reloadTableView() {
        tableView.reloadData()
    }
    
    func toggleLoadingIndicator(loading: Bool) {
        if loading {
            loadingIndicator.startAnimating()
        } else {
            loadingIndicator.stopAnimating()
        }
    }
    
    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        if parent == nil {
            viewModel?.viewClosed()
        }
    }
    
    func circularIcon(with color: UIColor, size: CGSize, icon: UIImage? = nil) -> UIImage? {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)

        UIBezierPath(roundedRect: rect, cornerRadius: 5).addClip()

        color.setFill()
        UIRectFill(rect)

        if let icon = icon {
            let iconRect = CGRect(x: (rect.size.width - icon.size.width) / 2,
                                  y: (rect.size.height - icon.size.height) / 2,
                                  width: icon.size.width,
                                  height: icon.size.height)
            icon.draw(in: iconRect, blendMode: .normal, alpha: 1.0)
        }

        defer { UIGraphicsEndImageContext() }

        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    func toggleOverlayLoading(show: Bool) {
        if let existingOverlayLoader = overlayLoader {
            existingOverlayLoader.removeFromSuperview()
            self.overlayLoader = nil
        }
        if show {
            self.overlayLoader = OverlayLoader()
            self.overlayLoader?.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(self.overlayLoader!)
            self.overlayLoader?.constraintToParent(parent: view)
        }
    }
    
}

extension NotificationsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.notifications.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let notification = viewModel?.notifications[indexPath.row] else { return UITableViewCell() }
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell", for: indexPath) as! NotificationCell
        cell.configure(notification: notification)
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let notification = viewModel?.notifications[indexPath.row] else { return }
        viewModel?.didSelectNotification(notification: notification)
    }
}

extension NotificationsViewController: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard let notification = viewModel?.notifications[indexPath.row] else { return nil }
        
        switch orientation {
        case .left:
            let deleteAction = SwipeAction(style: .destructive, title: nil) { action, indexPath in
                self.viewModel?.notificationSwipedToDelete(notification: notification)
            }
            deleteAction.hidesWhenSelected = true
            deleteAction.image = circularIcon(with: UIColor(named: "zenRed")!, size: CGSize(width: 56, height: 56), icon: UIImage(named: "ic_swipe_delete"))
            deleteAction.backgroundColor = UIColor.clear
            return [deleteAction]
        default: break
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeTableOptions()
        options.backgroundColor = .clear
        options.transitionStyle = .border
        options.buttonPadding = 0
        options.minimumButtonWidth = 61
        options.maximumButtonWidth = 61
        return options
    }
}
