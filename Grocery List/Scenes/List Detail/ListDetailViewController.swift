//
//  ListDetailViewController.swift
//  Grocery List
//
//  Created by Joe Benton on 18/06/2020.
//  Copyright © 2020 Joe Benton. All rights reserved.
//

import UIKit
import SwipeCellKit

class ListDetailViewController: UIViewController, StoryboardBased, ViewModelBased {

    var viewModel: ListDetailViewModel? {
        didSet {
            viewModel?.viewController = self
        }
    }
    
    var overlayLoader: OverlayLoader?
    var editListBtn: UIBarButtonItem?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addMoreItemsBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
    }
    
    fileprivate func configureTableView() {
        tableView.estimatedRowHeight = 50
        tableView.rowHeight = UITableView.automaticDimension
        
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
    
    func toggleListLoading(loading: Bool) {
        if let existingOverlayLoader = overlayLoader {
            existingOverlayLoader.removeFromSuperview()
            self.overlayLoader = nil
        }
        if loading {
            self.overlayLoader = OverlayLoader()
            self.overlayLoader?.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(self.overlayLoader!)
            self.overlayLoader?.constraintToParent(parent: view)
        }
        
        addMoreItemsBtn.isHidden = loading
    }
    
    func setTitle(title: String) {
        self.title = title
    }
    
    func reloadTableView() {
        tableView.reloadData()
    }
    
    func setAddMoreItemsBtnTitle(title: String) {
        UIView.performWithoutAnimation {
            addMoreItemsBtn.setTitle(title, for: .normal)
            addMoreItemsBtn.setTitle(title, for: .selected)
            addMoreItemsBtn.layoutIfNeeded()
        }
    }
    
    func configureNavigationButtons(shareCount: Int) {
        switch viewModel?.list?.viewAs {
        case .owner:
            editListBtn = UIBarButtonItem(image: UIImage(named: "ic_edit"), style: .plain, target: self, action: #selector(editBtnPressed))
            navigationItem.rightBarButtonItems = [createShareBtn(shareCount: shareCount), editListBtn!]
        case .collaborator:
            editListBtn = UIBarButtonItem(image: UIImage(named: "ic_edit"), style: .plain, target: self, action: #selector(editBtnPressed))
            navigationItem.rightBarButtonItems = [editListBtn!]
        default: break
        }
    }
    
    func showEditActionSheet() {
        let listName = viewModel?.list?.name ?? "List"
        let actionSheetVC = UIAlertController(title: "\(listName) Options", message: nil, preferredStyle: .actionSheet)
        
        let addItemsAction = UIAlertAction(title: "Add Items", style: .default) { (action) in
            self.viewModel?.addItemsSelected()
        }
        actionSheetVC.addAction(addItemsAction)
                
        switch viewModel?.list?.viewAs {
        case .owner:
            let editListAction = UIAlertAction(title: "Edit List Details", style: .default) { (action) in
                self.viewModel?.editListSelected()
            }
            actionSheetVC.addAction(editListAction)
            
            let deleteAction = UIAlertAction(title: "Delete List", style: .destructive) { (action) in
                self.viewModel?.deleteListSelected()
            }
            actionSheetVC.addAction(deleteAction)
        case .collaborator:
            let leaveAction = UIAlertAction(title: "Leave List", style: .destructive) { (action) in
                self.viewModel?.leaveListSelected()
            }
            actionSheetVC.addAction(leaveAction)
        default: break
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        actionSheetVC.addAction(cancelAction)
        
        if let presenter = actionSheetVC.popoverPresentationController {
            presenter.barButtonItem = editListBtn
        }
        
        present(actionSheetVC, animated: true, completion: nil)
    }
    
    func showConfirmDeleteItem(item: Item) {
        let confirmAlert = UIAlertController(title: "Delete \(item.name)", message: "Are you sure you want to delete this item?", preferredStyle: .alert)
           
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (action) in
           self.viewModel?.confirmDeleteItem(item: item)
        }
        confirmAlert.addAction(deleteAction)
           
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
        }
        confirmAlert.addAction(cancelAction)
           
        present(confirmAlert, animated: true, completion: nil)
    }
    
    @IBAction func addMoreItemsBtnPressed(_ sender: Any) {
        viewModel?.addMoreItemsBtnPressed()
    }
    
    @objc func editBtnPressed() {
        viewModel?.editBtnPressed()
    }
    
    @objc func shareListBtnPressed() {
        viewModel?.shareListBtnPressed()
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
    
    func showConfirmDeleteListAlert() {
        let alert = UIAlertController(title: "Delete List", message: "Are you sure you want to delete this list?", preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (action) in
            self.viewModel?.deleteListConfirmed()
        }
        alert.addAction(deleteAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    func showConfirmLeaveListAlert() {
        let alert = UIAlertController(title: "Leave List", message: "Are you sure you want to leave this shared list? You will no longer have access to it and will need to be reinvited by the owner.", preferredStyle: .alert)
        let leaveAction = UIAlertAction(title: "Leave", style: .destructive) { (action) in
            self.viewModel?.leaveListConfirmed()
        }
        alert.addAction(leaveAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    func createShareBtn(shareCount: Int) -> UIBarButtonItem {
        let shareView = UIView(frame: CGRect(x: 0, y: 0, width: 46, height: 44))
        shareView.translatesAutoresizingMaskIntoConstraints = false
        
        let shareBtn = UIButton(type: .system)
        shareBtn.setImage(UIImage(named: "ic_share"), for: .normal)
        shareBtn.addTarget(self, action: #selector(shareListBtnPressed), for: .touchUpInside)
        shareBtn.translatesAutoresizingMaskIntoConstraints = false
        shareView.addSubview(shareBtn)
        shareBtn.constraintToParent(parent: shareView)
        shareBtn.heightAnchor.constraint(equalToConstant: 44).isActive = true
        shareBtn.widthAnchor.constraint(equalToConstant: 46).isActive = true
        
        if shareCount > 0 {
            let unreadLabel = UILabel()
            unreadLabel.text = "\(shareCount)"
            unreadLabel.font = UIFont.systemFont(ofSize: 9, weight: .semibold)
            unreadLabel.textColor = UIColor.white
            unreadLabel.backgroundColor = UIColor(named: "zenOrange")
            unreadLabel.textAlignment = .center
            unreadLabel.layer.borderColor = UIColor.white.cgColor
            unreadLabel.layer.borderWidth = 1
            unreadLabel.layer.cornerRadius = 8
            unreadLabel.clipsToBounds = true
            unreadLabel.translatesAutoresizingMaskIntoConstraints = false
            shareView.addSubview(unreadLabel)
            unreadLabel.trailingAnchor.constraint(equalTo: shareView.trailingAnchor, constant: -4).isActive = true
            unreadLabel.bottomAnchor.constraint(equalTo: shareView.bottomAnchor, constant: -6).isActive = true
            unreadLabel.heightAnchor.constraint(equalToConstant: 16).isActive = true
            unreadLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 16).isActive = true
        }
        
        return UIBarButtonItem(customView: shareView)
    }
    
    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        if parent == nil {
            viewModel?.viewClosed()
        }
    }
}

extension ListDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.items.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let item = viewModel?.items[indexPath.row] else { return UITableViewCell() }
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) as! ItemCell
        cell.configure(item: item)
        cell.itemDelegate = self
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}

extension ListDetailViewController: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard let item = viewModel?.items[indexPath.row] else { return nil }
        
        switch orientation {
        case .left:
            let deleteAction = SwipeAction(style: .destructive, title: nil) { action, indexPath in
                self.viewModel?.itemSwipedToDelete(item: item)
            }
            deleteAction.hidesWhenSelected = true
            deleteAction.image = circularIcon(with: UIColor(named: "zenRed")!, size: CGSize(width: 50, height: 50), icon: UIImage(named: "ic_swipe_delete"))
            deleteAction.backgroundColor = UIColor.clear
            return [deleteAction]
        case .right:
            let editAction = SwipeAction(style: .default, title: nil) { action, indexPath in
                self.viewModel?.itemSwipedToEdit(item: item)
            }
            editAction.hidesWhenSelected = true
            editAction.image = circularIcon(with: UIColor(named: "zenBlue")!, size: CGSize(width: 50, height: 50), icon: UIImage(named: "ic_swipe_edit"))
            editAction.backgroundColor = UIColor.clear
            
            return [editAction]
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeTableOptions()
        options.backgroundColor = .clear
        options.transitionStyle = .border
        options.buttonPadding = 0
        options.minimumButtonWidth = 55
        options.maximumButtonWidth = 55
        return options
    }
}


extension ListDetailViewController: ItemCellDelegate {
    func didPressCheckedBtn(item: Item, checked: Bool) {
        viewModel?.checkedBtnPressed(item: item, checked: checked)
    }
}
