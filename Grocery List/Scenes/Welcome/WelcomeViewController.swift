//
//  WelcomeViewController.swift
//  Grocery List
//
//  Created by Joe Benton on 18/06/2020.
//  Copyright © 2020 Joe Benton. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController, StoryboardBased, ViewModelBased {

    var viewModel: WelcomeViewModel? {
        didSet {
            viewModel?.viewController = self
        }
    }
    
    private var pageViewController: UIPageViewController!
    private var sliderContentViewControllers: [UIViewController] = []
    private var inviteBannerView: UIView?
    
    @IBOutlet weak var sliderContainerView: UIView!
    @IBOutlet weak var registerBtn: UIButton!
    @IBOutlet weak var loginBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel?.setupViewController()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        viewModel?.viewReady()
    }
    
    @IBAction func registerBtnPressed(_ sender: Any) {
        viewModel?.registerBtnPressed()
    }

    @IBAction func loginBtnPressed(_ sender: Any) {
        viewModel?.loginBtnPressed()
    }
    
    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        if parent == nil {
            viewModel?.viewClosed()
        }
    }
     
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if let vc = segue.destination as? UIPageViewController {
            pageViewController = vc
            pageViewController.dataSource = self
            pageViewController.delegate = self
        }
    }
    
    func setSliderPages(contentArray: Array<WelcomeSliderContent>) {
        sliderContentViewControllers = []

        let storyboard = UIStoryboard(name: "WelcomeViewController", bundle: nil)
        
        for pageContent in contentArray {
            guard let sliderContentVC = storyboard.instantiateViewController(withIdentifier: "welcomeSliderContentVC") as? WelcomeSliderContentViewController else { break }
            sliderContentVC.pageContent = pageContent
            sliderContentViewControllers.append(sliderContentVC)
        }
        
        guard let firstPageContentVC = sliderContentViewControllers.first else { return }
        pageViewController.setViewControllers([firstPageContentVC], direction: .forward, animated: true, completion: nil)
    }
    
    func showIncomingInviteBanner() {
        if let existingInviteBannerView = self.inviteBannerView {
            existingInviteBannerView.removeFromSuperview()
        }
        
        inviteBannerView = UIView()
        inviteBannerView?.layer.cornerRadius = 5
        inviteBannerView?.clipsToBounds = true
        inviteBannerView?.backgroundColor = UIColor(named: "zenLightGrey")
        inviteBannerView?.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(inviteBannerView!)
        inviteBannerView?.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15).isActive = true
        inviteBannerView?.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15).isActive = true
        inviteBannerView?.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15).isActive = true
        
        let label = UILabel()
        label.text = "Register an account or login to use the list invite link."
        label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        label.textColor = UIColor(named: "zenBlack")
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        inviteBannerView?.addSubview(label)
        label.leadingAnchor.constraint(equalTo: inviteBannerView!.leadingAnchor, constant: 10).isActive = true
        label.trailingAnchor.constraint(equalTo: inviteBannerView!.trailingAnchor, constant: -10).isActive = true
        label.topAnchor.constraint(equalTo: inviteBannerView!.topAnchor, constant: 10).isActive = true
        label.bottomAnchor.constraint(equalTo: inviteBannerView!.bottomAnchor, constant: -10).isActive = true
    }
}

extension WelcomeViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = sliderContentViewControllers.firstIndex(of: viewController) else {
            return nil
        }

        let previousIndex = viewControllerIndex - 1

        guard previousIndex >= 0 else {
            return nil
        }

        guard sliderContentViewControllers.count > previousIndex else {
            return nil
        }
        return sliderContentViewControllers[previousIndex]
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = sliderContentViewControllers.firstIndex(of: viewController) else {
            return nil
        }

        let nextIndex = viewControllerIndex + 1
        let viewControllersCount = sliderContentViewControllers.count

        guard viewControllersCount != nextIndex else {
            return nil
        }

        guard viewControllersCount > nextIndex else {
            return nil
        }
        return sliderContentViewControllers[nextIndex]
    }
}

extension WelcomeViewController: UIPageViewControllerDelegate {
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return sliderContentViewControllers.count
    }
     
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }
}
