//
//  ListsCategoryViewController.swift
//  Grocery List
//
//  Created by Joe Benton on 18/06/2020.
//  Copyright © 2020 Joe Benton. All rights reserved.
//

import UIKit
import SwipeCellKit

class ListsCategoryViewController: UIViewController, StoryboardBased, ViewModelBased {

    var viewModel: ListsCategoryViewModel? {
        didSet {
            viewModel?.viewController = self
        }
    }
    
    var pageHeaderLayer: CALayer?
    var overlayLoader: OverlayLoader?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var emptyLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addPageHeaderLayer()
        configureTableView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updatePageHeaderFrame()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel?.viewReady()
        
        configureNavBarStyle()
        configureBackStyleOnNavChange()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.tintColor = UIColor(named: "zenBlue")
    }
    
    fileprivate func configureNavBarStyle() {
        let compactAppearance = UINavigationBarAppearance()
        compactAppearance.configureWithDefaultBackground()
        let compactButtonAppearance = UIBarButtonItemAppearance(style: .plain)
        compactButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor(named: "zenBlack")!]
        compactAppearance.buttonAppearance = compactButtonAppearance
        let compactBackButtonAppearance = UIBarButtonItemAppearance(style: .plain)
        compactBackButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor(named: "zenBlue")!]
        compactAppearance.backButtonAppearance = compactBackButtonAppearance
        
        let largeAppearance = UINavigationBarAppearance()
        largeAppearance.configureWithTransparentBackground()
        let largeButtonAppearance = UIBarButtonItemAppearance(style: .plain)
        largeButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor(named: "zenBgWhite")!]
        largeAppearance.buttonAppearance = largeButtonAppearance
        largeAppearance.largeTitleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 28, weight: .bold)
        ]
        
        navigationController?.navigationBar.standardAppearance = compactAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = largeAppearance
    }
    
    fileprivate func addPageHeaderLayer() {
        pageHeaderLayer = CALayer()
        let headerImage = UIImage(named: "ic_pageHeader")?.cgImage
        pageHeaderLayer?.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 220)
        pageHeaderLayer?.contents = headerImage
        view.layer.insertSublayer(pageHeaderLayer!, below: tableView.layer)
    }
    
    fileprivate func updatePageHeaderFrame() {
        pageHeaderLayer?.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 220)
    }
    
    fileprivate func configureTableView() {
        tableView.estimatedRowHeight = 72
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView()
        
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 40, right: 0)
    }
    
    func setTitle(title: String) {
        self.title = title
    }
    
    func toggleListsLoading(loading: Bool) {
        if loading {
            loadingIndicator.startAnimating()
        } else {
            loadingIndicator.stopAnimating()
        }
    }
    
    func reloadTableView() {
        tableView.reloadData()
    }
    
    func showConfirmDeleteList(list: List) {
        let confirmAlert = UIAlertController(title: "Delete \(list.name)", message: "Are you sure you want to delete this list?", preferredStyle: .alert)
           
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (action) in
            self.viewModel?.confirmDeleteList(list: list)
        }
        confirmAlert.addAction(deleteAction)
           
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
        }
        confirmAlert.addAction(cancelAction)
           
        present(confirmAlert, animated: true, completion: nil)
    }
    
    func showConfirmLeaveList(list: List) {
        let confirmAlert = UIAlertController(title: "Leave \(list.name)", message: "Are you sure you want to leave this shared list? You will no longer have access to it and will need to be reinvited by the owner.", preferredStyle: .alert)
           
        let leaveAction = UIAlertAction(title: "Leave", style: .destructive) { (action) in
            self.viewModel?.confirmLeaveList(list: list)
        }
        confirmAlert.addAction(leaveAction)
           
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
        }
        confirmAlert.addAction(cancelAction)
           
        present(confirmAlert, animated: true, completion: nil)
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
    
    func toggleEmptyListLabel(show: Bool) {
        emptyLabel.isHidden = !show
    }
    
    fileprivate func configureBackStyleOnNavChange() {
        guard let navBarHeight = navigationController?.navigationBar.frame.height else {
            return
        }
        let padding: CGFloat = 16.0
        if navBarHeight >= (44.0 + padding) {
            navigationController?.navigationBar.tintColor = UIColor.white
        } else {
            navigationController?.navigationBar.tintColor = UIColor(named: "zenBlue")
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
    
    func setUnreadNotificationsCount(unreadCount: Int) {
        let notificationsView = UIView(frame: CGRect(x: 0, y: 0, width: 46, height: 44))
        notificationsView.translatesAutoresizingMaskIntoConstraints = false
        
        let notificationsBtn = UIButton(type: .system)
        notificationsBtn.setImage(UIImage(named: "ic_notifications"), for: .normal)
        notificationsBtn.addTarget(self, action: #selector(notificationsBtnPressed), for: .touchUpInside)
        notificationsBtn.tintColor = UIColor.white
        notificationsBtn.translatesAutoresizingMaskIntoConstraints = false
        notificationsView.addSubview(notificationsBtn)
        notificationsBtn.constraintToParent(parent: notificationsView)
        notificationsBtn.heightAnchor.constraint(equalToConstant: 44).isActive = true
        notificationsBtn.widthAnchor.constraint(equalToConstant: 46).isActive = true
        
        if unreadCount > 0 {
            let unreadLabel = UILabel()
            unreadLabel.text = "\(unreadCount)"
            unreadLabel.font = UIFont.systemFont(ofSize: 9, weight: .semibold)
            unreadLabel.textColor = UIColor.white
            unreadLabel.backgroundColor = UIColor(named: "zenOrange")
            unreadLabel.textAlignment = .center
            unreadLabel.layer.borderColor = UIColor.white.cgColor
            unreadLabel.layer.borderWidth = 1
            unreadLabel.layer.cornerRadius = 8
            unreadLabel.clipsToBounds = true
            unreadLabel.translatesAutoresizingMaskIntoConstraints = false
            notificationsView.addSubview(unreadLabel)
            unreadLabel.trailingAnchor.constraint(equalTo: notificationsView.trailingAnchor, constant: -4).isActive = true
            unreadLabel.bottomAnchor.constraint(equalTo: notificationsView.bottomAnchor, constant: -6).isActive = true
            unreadLabel.heightAnchor.constraint(equalToConstant: 16).isActive = true
            unreadLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 16).isActive = true
        }
        
        let notificationsBarBtn = UIBarButtonItem(customView: notificationsView)
        navigationItem.rightBarButtonItem = notificationsBarBtn
    }
    
    @IBAction func notificationsBtnPressed(_ sender: Any) {
        viewModel?.notificationsBtnPressed()
    }
    
    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        if parent == nil {
            viewModel?.viewClosed()
        }
    }
}

extension ListsCategoryViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.lists.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let list = viewModel?.lists[indexPath.row] else { return UITableViewCell() }
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell", for: indexPath) as! ListCell
        let categoryType = viewModel?.categoryType ?? .all
        cell.configure(list: list, categoryType: categoryType)
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let list = viewModel?.lists[indexPath.row] else { return }
        viewModel?.didSelectList(list: list)
    }
}

extension ListsCategoryViewController: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard let list = viewModel?.lists[indexPath.row] else { return nil }
        
        switch orientation {
        case .left:
            let deleteAction = SwipeAction(style: .destructive, title: nil) { action, indexPath in
                self.viewModel?.listSwipedToDelete(list: list)
            }
            deleteAction.hidesWhenSelected = true
            deleteAction.image = circularIcon(with: UIColor(named: "zenRed")!, size: CGSize(width: 56, height: 56), icon: UIImage(named: "ic_swipe_delete"))
            deleteAction.backgroundColor = UIColor.clear
            return [deleteAction]
        case .right:
            switch list.viewAs {
            case .owner:
                let editAction = SwipeAction(style: .default, title: nil) { action, indexPath in
                    self.viewModel?.listSwipedToEdit(list: list)
                }
                editAction.hidesWhenSelected = true
                editAction.image = circularIcon(with: UIColor(named: "zenOrange")!, size: CGSize(width: 56, height: 56), icon: UIImage(named: "ic_swipe_edit"))
                editAction.backgroundColor = UIColor.clear
                
                let shareAction = SwipeAction(style: .default, title: nil) { action, indexPath in
                    self.viewModel?.listSwipedToShare(list: list)
                }
                shareAction.hidesWhenSelected = true
                shareAction.image = circularIcon(with: UIColor(named: "zenBlue")!, size: CGSize(width: 56, height: 56), icon: UIImage(named: "ic_swipe_share"))
                shareAction.backgroundColor = UIColor.clear
                
                let completeAction = SwipeAction(style: .default, title: nil) { action, indexPath in
                    self.viewModel?.listSwipedToComplete(list: list)
                }
                completeAction.hidesWhenSelected = true
                completeAction.image = circularIcon(with: UIColor(named: "zenGreen")!, size: CGSize(width: 56, height: 56), icon: UIImage(named: "ic_swipe_completed"))
                completeAction.backgroundColor = UIColor.clear
                
                return [completeAction, shareAction, editAction]
            case .collaborator:
                return []
            }
        }
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

extension ListsCategoryViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        configureBackStyleOnNavChange()
    }
}
