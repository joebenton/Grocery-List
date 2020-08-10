//
//  OverlayLoader.swift
//  Grocery List
//
//  Created by Joe Benton on 23/06/2020.
//  Copyright © 2020 Joe Benton. All rights reserved.
//

import UIKit

class OverlayLoader: UIView {

    var loadingView: UIView?
    var loadingSpinner: UIActivityIndicatorView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setupView()
    }

    fileprivate func setupView() {
        backgroundColor = UIColor.white.withAlphaComponent(0.6)
        
        setupLoadingSpinner()
    }
    
    fileprivate func setupLoadingSpinner() {
        if let existingLoadingView = self.loadingView {
            existingLoadingView.removeFromSuperview()
            self.loadingView = nil
        }
        if let existingLoadingSpinner = self.loadingSpinner {
            existingLoadingSpinner.removeFromSuperview()
            self.loadingSpinner = nil
        }
        
        loadingView = UIView()
        loadingView?.backgroundColor = UIColor.white
        loadingView?.layer.cornerRadius = 10
        loadingView?.clipsToBounds = true
        loadingView?.translatesAutoresizingMaskIntoConstraints = false
        addSubview(loadingView!)
        loadingView?.widthAnchor.constraint(equalToConstant: 80).isActive = true
        loadingView?.heightAnchor.constraint(equalToConstant: 80).isActive = true
        loadingView?.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        loadingView?.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        loadingSpinner = UIActivityIndicatorView(style: .medium)
        loadingSpinner?.startAnimating()
        loadingSpinner?.color = UIColor(named: "zenBlack")
        loadingSpinner?.translatesAutoresizingMaskIntoConstraints = false
        loadingView?.addSubview(loadingSpinner!)
        loadingSpinner?.centerYAnchor.constraint(equalTo: loadingView!.centerYAnchor).isActive = true
        loadingSpinner?.centerXAnchor.constraint(equalTo: loadingView!.centerXAnchor).isActive = true
    }
    
}
