//
//  WelcomeViewModel.swift
//  Grocery List
//
//  Created by Joe Benton on 18/06/2020.
//  Copyright © 2020 Joe Benton. All rights reserved.
//

import UIKit

class WelcomeViewModel: ViewModel {

    weak var coordinator: WelcomeCoordinator?
    weak var viewController: WelcomeViewController?

    var sliderPagesContent = Array<WelcomeSliderContent>()
    
    init(with coordinator: WelcomeCoordinator) {
        self.coordinator = coordinator
    }

    func setupViewController() {
        buildSliderContent()
    }
    
    func viewReady() {
        if let _ = UserDefaults.standard.value(forKey: Config.userDefaultKeys.incomingListInviteListUid) as? String,
            let _ = UserDefaults.standard.value(forKey: Config.userDefaultKeys.incomingListInviteInviteUid) as? String {
            showInviteBanner()
        }
    }

    func registerBtnPressed() {
        coordinator?.gotoRegister()
    }
    
    func loginBtnPressed() {
        coordinator?.gotoLogin()
    }
    
    func viewClosed() {
        coordinator?.finish()
    }
    
    fileprivate func buildSliderContent() {
        sliderPagesContent = [
            WelcomeSliderContent(index: 0, totalPages: 3, image: UIImage(named: "ic_welcome1")!, text: "A grocery list helps you stick to a healthy eating plan, and your wellbeing"),
            WelcomeSliderContent(index: 1, totalPages: 3, image: UIImage(named: "ic_welcome2")!, text: "Organize your grocery shopping so you save money & buy only what you need"),
            WelcomeSliderContent(index: 2, totalPages: 3, image: UIImage(named: "ic_welcome3")!, text: "Share grocery lists with family & friends so you help each other get things done and save time")
        ]
        viewController?.setSliderPages(contentArray: sliderPagesContent)
    }
    
    func showInviteBanner() {
        viewController?.showIncomingInviteBanner()
    }
}
