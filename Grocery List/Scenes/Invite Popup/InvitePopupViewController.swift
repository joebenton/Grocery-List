//
//  InvitePopupViewController.swift
//  Grocery List
//
//  Created by Joe Benton on 16/07/2020.
//  Copyright © 2020 Joe Benton. All rights reserved.
//

import UIKit

class InvitePopupViewController: UIViewController, StoryboardBased, ViewModelBased {

    var viewModel: InvitePopupViewModel? {
        didSet {
            viewModel?.viewController = self
        }
    }
    
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var acceptBtn: LoadingButton!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var labelText: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
    }
    
    fileprivate func configureView() {
        popupView.layer.cornerRadius = 10
        popupView.clipsToBounds = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel?.viewReady()
    }
    
    func toggleAcceptBtnLoading(loading: Bool) {
        acceptBtn.toggleLoading(loading: loading)
    }
    
    func toggleInviteLoading(loading: Bool) {
        if loading {
            loadingIndicator.isHidden = false
            loadingIndicator.startAnimating()
            
            labelText.isHidden = true
        } else {
            loadingIndicator.isHidden = true
            loadingIndicator.stopAnimating()
            
            labelText.isHidden = false
        }
    }
    
    func setLabelText(text: String) {
        labelText.text = text
    }
    
    @IBAction func cancelBtnPressed(_ sender: Any) {
        viewModel?.cancelBtnPressed()
    }
    
    @IBAction func acceptBtnPressed(_ sender: Any) {
        viewModel?.acceptBtnPressed()
    }
    
    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        if parent == nil {
            viewModel?.viewClosed()
        }
    }
}
