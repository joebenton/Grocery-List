//
//  ListsHomeViewController.swift
//  Grocery List
//
//  Created by Joe Benton on 18/06/2020.
//  Copyright © 2020 Joe Benton. All rights reserved.
//

import UIKit

class ListsHomeViewController: UIViewController, StoryboardBased, ViewModelBased {

    var viewModel: ListsHomeViewModel? {
        didSet {
            viewModel?.viewController = self
        }
    }
    
    var addTooltip: AddTooltip?
    var pageHeaderLayer: CALayer?
    var notificationsBarBtn: UIBarButtonItem?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
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
    }
    
    fileprivate func configureNavBarStyle() {
        let compactAppearance = UINavigationBarAppearance()
        compactAppearance.configureWithDefaultBackground()
        let compactButtonAppearance = UIBarButtonItemAppearance(style: .plain)
        compactButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor(named: "zenBlack")!]
        compactAppearance.buttonAppearance = compactButtonAppearance
        
        let largeAppearance = UINavigationBarAppearance()
        largeAppearance.configureWithTransparentBackground()
        let largeButtonAppearance = UIBarButtonItemAppearance(style: .plain)
        largeButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white]
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
    
    func reloadTableView() {
        tableView.reloadData()
    }
    
    func toggleEmptyTooltip(show: Bool) {
        if let existingAddTooltip = addTooltip {
            existingAddTooltip.removeFromSuperview()
        }
        if show {
            addTooltip = AddTooltip()
            addTooltip?.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(addTooltip!)
            addTooltip!.constraintToParent(parent: view)
        }
    }
    
    func toggleLoadingIndicator(loading: Bool) {
        switch loading {
        case true:
            loadingIndicator.startAnimating()
        case false:
            loadingIndicator.stopAnimating()
        }
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
    
    @objc func notificationsBtnPressed() {
        viewModel?.notificationsBtnPressed()
    }
}

extension ListsHomeViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.categories.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let category = viewModel?.categories[indexPath.row] else { return UITableViewCell() }
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as! CategoryCell
        cell.configure(category: category)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let category = viewModel?.categories[indexPath.row] else { return }
        viewModel?.didSelectCategory(category: category)
    }
}
