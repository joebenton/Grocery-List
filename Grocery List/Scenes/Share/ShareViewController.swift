//
//  ShareViewController.swift
//  Grocery List
//
//  Created by Joe Benton on 16/07/2020.
//  Copyright © 2020 Joe Benton. All rights reserved.
//

import UIKit
import SwipeCellKit

class ShareViewController: UIViewController, StoryboardBased, ViewModelBased {

    var viewModel: ShareViewModel? {
        didSet {
            viewModel?.viewController = self
        }
    }
    
    var overlayLoader: OverlayLoader?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeader: UIView!
    @IBOutlet weak var addUserFormFieldView: FormFieldView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configTableView()
        configTableViewHeader()
        configFormFieldView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        configTableViewHeader()
    }
    
    fileprivate func configTableView() {
        tableView.estimatedRowHeight = 50
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView()
    }
    
    fileprivate func configTableViewHeader() {
        if let headerView = tableView.tableHeaderView {
            let height = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
            var frame = headerView.frame
            frame.size.height = height
            headerView.frame = frame
            tableView.tableHeaderView = headerView
            headerView.setNeedsLayout()
            headerView.layoutIfNeeded()
        }
    }
    
    fileprivate func configFormFieldView() {
        addUserFormFieldView.setTitle(title: "Create a new Share Link for")
        addUserFormFieldView.setPlaceholder(placeholder: "Enter new name")
        addUserFormFieldView.setKeyboardReturnKeyType(type: .go)
        addUserFormFieldView.fieldDelegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel?.viewReady()
        
        configureNavBarStyle()
    }
    
    func reloadTableView() {
        tableView.reloadData()
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
    
    func showSharedInviteShareSheet(url: String, cellRect: CGRect) {
        guard let linkUrl = URL(string: url) else { return }
        let shareLinkActivityItem = ShareLinkActivityItem( message: "Join my Grocery List by using this link: \(linkUrl.absoluteString)", url: linkUrl)
        let activityViewController = UIActivityViewController(activityItems: [shareLinkActivityItem], applicationActivities: nil)
        if let popOver = activityViewController.popoverPresentationController {
            popOver.sourceView = self.view
            popOver.sourceRect = self.view.convert(cellRect, from: tableView)
        }
        present(activityViewController, animated: true, completion: nil)
    }
    
    func showDeleteLinkConfirmPopup(inviteUid: String) {
        let alertVC = UIAlertController(title: "Are you sure?", message: "Are you sure you want to delete this share link? It will no longer be available for the user to join this list?", preferredStyle: .alert)
        
        let yesAction = UIAlertAction(title: "Delete", style: .destructive) { (action) in
            self.viewModel?.deleteLinkConfirmed(inviteUid: inviteUid)
        }
        alertVC.addAction(yesAction)
        
        let noActon = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertVC.addAction(noActon)
        
        present(alertVC, animated: true, completion: nil)
    }
    
    func showDeleteUserConfirmPopup(userUid: String) {
        let alertVC = UIAlertController(title: "Are you sure?", message: "Are you sure you want to remove this user from the list? They will no longer be able to view or edit the list?", preferredStyle: .alert)
       
       let yesAction = UIAlertAction(title: "Remove", style: .destructive) { (action) in
           self.viewModel?.deleteUserConfirmed(userUid: userUid)
       }
       alertVC.addAction(yesAction)
       
       let noActon = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
       alertVC.addAction(noActon)
       
       present(alertVC, animated: true, completion: nil)
    }
    
    func resetNewLinkField() {
        addUserFormFieldView.resignActiveField()
        addUserFormFieldView.setFieldValue(text: "")
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
    
    @IBAction func createLinkBtnPressed(_ sender: Any) {
        viewModel?.addNewLink(name: addUserFormFieldView.getFieldValue().trimmingCharacters(in: .whitespaces), addBtnRect: addUserFormFieldView.frame)
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
    
    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        if parent == nil {
            viewModel?.viewClosed()
        }
    }
}

extension ShareViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.listUsers.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let listUser = viewModel?.listUsers[indexPath.row] else { return UITableViewCell() }
        let cell = tableView.dequeueReusableCell(withIdentifier: "ShareUserCell", for: indexPath) as! ShareUserCell
        cell.configure(listUser: listUser)
        cell.shareDelegate = self
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        guard let listUser = viewModel?.listUsers[indexPath.row] else { return false }
        switch listUser.type {
        case .pendingInvite:
            return true
        default:
            return false
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let listUser = viewModel?.listUsers[indexPath.row] else { return }
        let cell = tableView.cellForRow(at: indexPath)
        let cellRect = cell?.frame ?? tableView.frame
        viewModel?.didSelectListUser(listUser: listUser, cellRect: cellRect)
    }
}

extension ShareViewController: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard let listUser = viewModel?.listUsers[indexPath.row] else { return nil }
        
        if case .user(let user, _) = listUser.type {
            if user.role == .owner {
                return nil
            }
        }
        
        switch orientation {
        case .left:
            let deleteAction = SwipeAction(style: .destructive, title: nil) { action, indexPath in
                self.viewModel?.listUserSwipedToDelete(listUser: listUser)
            }
            deleteAction.hidesWhenSelected = true
            deleteAction.image = circularIcon(with: UIColor(named: "zenRed")!, size: CGSize(width: 56, height: 50), icon: UIImage(named: "ic_swipe_delete"))
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


extension ShareViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == addUserFormFieldView.field {
            viewModel?.addNewLink(name: addUserFormFieldView.getFieldValue().trimmingCharacters(in: .whitespaces), addBtnRect: addUserFormFieldView.frame)
        }
        return true
    }
}

extension ShareViewController: ShareUserCellDelegate {
    func linkBtnPressed(listUser: ListUser, btnRect: CGRect) {
        viewModel?.linkBtnPressed(listUser: listUser, btnRect: btnRect)
    }
    
    func deleteBtnPressed(listUser: ListUser) {
        viewModel?.deleteBtnPressed(listUser: listUser)
    }
}
