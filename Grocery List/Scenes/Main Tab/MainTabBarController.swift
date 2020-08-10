//
//  MainTabController.swift
//  Grocery List
//
//  Created by Joe Benton on 18/06/2020.
//  Copyright © 2020 Joe Benton. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController, StoryboardBased, ViewModelBased {

    var viewModel: MainTabBarViewModel? {
        didSet {
            viewModel?.viewController = self
        }
    }
    var coordinator: MainTabCoordinator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupMiddleButton()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel?.viewReady()
    }
    
    func setupMiddleButton() {
        let buttonSize: CGFloat = 60.0
        let middleBtn = UIButton(frame: CGRect(x: (self.view.bounds.width / 2)-(buttonSize / 2), y: -(buttonSize / 2), width: buttonSize, height: buttonSize))
        middleBtn.translatesAutoresizingMaskIntoConstraints = false
        
        middleBtn.backgroundColor = UIColor(named: "zenBlue")
        middleBtn.tintColor = UIColor.white
        
        middleBtn.setImage(UIImage(named: "ic_tabBarPlus"), for: .normal)
        middleBtn.setImage(UIImage(named: "ic_tabBarPlus"), for: .selected)
        
        middleBtn.layer.cornerRadius = middleBtn.frame.width / 2
        middleBtn.clipsToBounds = true

        middleBtn.addTarget(self, action: #selector(middleButtonAction), for: .touchUpInside)
        
        tabBar.addSubview(middleBtn)

        middleBtn.centerXAnchor.constraint(equalTo: tabBar.centerXAnchor).isActive = true
        middleBtn.centerYAnchor.constraint(equalTo: tabBar.topAnchor).isActive = true
        middleBtn.widthAnchor.constraint(equalToConstant: buttonSize).isActive = true
        middleBtn.heightAnchor.constraint(equalToConstant: buttonSize).isActive = true
        
        let label = UILabel(frame: CGRect(x: middleBtn.frame.origin.x - 100, y: middleBtn.frame.origin.y, width: 200, height: 20))
        label.text = "Add a grocery list"
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = UIColor(named: "zenBlack")
        label.translatesAutoresizingMaskIntoConstraints = false
        tabBar.addSubview(label)
        label.topAnchor.constraint(equalTo: middleBtn.bottomAnchor, constant: 3).isActive = true
        label.centerXAnchor.constraint(equalTo: tabBar.centerXAnchor).isActive = true
        
        view.layoutIfNeeded()
    }

    @objc func middleButtonAction(sender: UIButton) {
        viewModel?.middleBtnPressed()
    }
    
    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        if parent == nil {
            viewModel?.viewClosed()
        }
    }
}
