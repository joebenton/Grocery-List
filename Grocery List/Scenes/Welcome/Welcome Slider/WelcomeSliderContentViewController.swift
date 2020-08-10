//
//  WelcomeSliderContentViewController.swift
//  Grocery List
//
//  Created by Joe Benton on 18/06/2020.
//  Copyright © 2020 Joe Benton. All rights reserved.
//

import UIKit

class WelcomeSliderContentViewController: UIViewController {

    var pageContent: WelcomeSliderContent?
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var contentImageView: UIImageView!
    @IBOutlet weak var contentLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureContent()
    }
    
    func configureContent() {
        guard let pageContent = self.pageContent else { return }
        
        contentImageView.image = pageContent.image
        
        pageControl.numberOfPages = pageContent.totalPages
        pageControl.currentPage = pageContent.index
        
        contentLabel.text = pageContent.text
    }
    
}
